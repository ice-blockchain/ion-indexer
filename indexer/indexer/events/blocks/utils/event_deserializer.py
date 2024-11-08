from __future__ import annotations

import base64

import msgpack

from indexer.core.database import MessageContent, Transaction, Message, Trace, TraceEdge

account_status_map = ['uninit', 'frozen', 'active', 'nonexist']


def _message_from_tuple(tx: Transaction, data, direction: str) -> Message:
    (msg_hash, source, destination, value, fwd_fee, ihr_fee, created_lt, created_at, opcode, ihr_disabled, bounce,
     bounced,
     import_fee, body_boc, init_state_boc) = data
    message_content = MessageContent(hash='', body=body_boc)
    message = Message(
        msg_hash=msg_hash,
        tx_hash=tx.hash,
        tx_lt=tx.lt,
        source=source,
        destination=destination,
        direction=direction,
        value=value,
        fwd_fee=fwd_fee,
        ihr_fee=ihr_fee,
        created_lt=created_lt,
        created_at=created_at,
        opcode=opcode,
        ihr_disabled=ihr_disabled,
        bounce=bounce,
        bounced=bounced,
        import_fee=import_fee,
        message_content=message_content,
        transaction=tx,
    )
    if init_state_boc is not None:
        message.init_state = MessageContent(hash='', body=init_state_boc)
    return message


def _tx_description_from_tuple(data):
    (credit_first, storage_ph_tuple, credit_ph_tuple, compute_ph_tuple, action, aborted, bounce, destroyed) = data
    storage_ph = {
        'storage_fees_collected': storage_ph_tuple[0],
        'storage_fees_due': storage_ph_tuple[1],
        'status_change': storage_ph_tuple[2]
    }
    credit_ph = {
        'due_fees_collected': credit_ph_tuple[0],
        'credit': credit_ph_tuple[1],
    }
    compute_ph_type = compute_ph_tuple[0]
    compute_ph = None
    if compute_ph_type == 0:
        compute_ph = {
            'type': 'skipped',
            'reason': compute_ph_tuple[1][0]
        }
    else:
        compute_ph = {
            'type': 'vm',
            'success': compute_ph_tuple[1][0],
            'msg_state_used': compute_ph_tuple[1][1],
            'account_activated': compute_ph_tuple[1][2],
            'gas_fees': compute_ph_tuple[1][3],
            'gas_used': compute_ph_tuple[1][4],
            'gas_limit': compute_ph_tuple[1][5],
            'gas_credit': compute_ph_tuple[1][6],
            'mode': compute_ph_tuple[1][7],
            'exit_code': compute_ph_tuple[1][8],
            'exit_arg': compute_ph_tuple[1][9],
            'vm_steps': compute_ph_tuple[1][10],
            'vm_init_state_hash': compute_ph_tuple[1][11],
            'vm_final_state_hash': compute_ph_tuple[1][12],
        }
    return {
        'credit_first': credit_first,
        'storage_ph': storage_ph,
        'credit_ph': credit_ph,
        'compute_ph': compute_ph,
        'aborted': aborted,
        'bounce': bounce,
        'destroyed': destroyed,
    }

def fill_tx_description(tx: Transaction, data):
    (credit_first, storage_ph_tuple, credit_ph_tuple, compute_ph_tuple, action, aborted, bounce, destroyed) = data
    tx.descr = 'ord'
    tx.credit_first = credit_first
    tx.aborted = aborted
    tx.bounce = bounce
    tx.destroyed = destroyed
    tx.storage_fees_collected = storage_ph_tuple[0]
    tx.storage_fees_due = storage_ph_tuple[1]
    match storage_ph_tuple[2]:
        case 0:
            tx.storage_fees_change = 'unchanged'
        case 1:
            tx.storage_fees_change = 'frozen'
        case 2:
            tx.storage_fees_change = 'deleted'
    tx.due_fees_collected = credit_ph_tuple[0]
    tx.credit = credit_ph_tuple[1]
    match compute_ph_tuple[0]:
        case 0:
            tx.compute_skipped = True
            tx.skipped_reason = compute_ph_tuple[1][0]
        case 1:
            tx.compute_mode = 'vm'
            tx.compute_success = compute_ph_tuple[1][0]
            tx.compute_msg_state_used = compute_ph_tuple[1][1]
            tx.compute_account_activated = compute_ph_tuple[1][2]
            tx.compute_gas_fees = compute_ph_tuple[1][3]
            tx.compute_gas_used = compute_ph_tuple[1][4]
            tx.compute_gas_limit = compute_ph_tuple[1][5]
            tx.compute_gas_credit = compute_ph_tuple[1][6]
            tx.compute_mode = compute_ph_tuple[1][7]
            tx.compute_exit_code = compute_ph_tuple[1][8]
            tx.compute_exit_arg = compute_ph_tuple[1][9]
            tx.compute_vm_steps = compute_ph_tuple[1][10]
            tx.compute_vm_init_state_hash = compute_ph_tuple[1][11]
            tx.compute_vm_final_state_hash = compute_ph_tuple[1][12]
    if action is not None:
        tx.action_success = action[0]
        tx.action_valid = action[1]
        tx.action_no_funds = action[2]
        tx.action_status_change = action[3]
        tx.action_total_fwd_fees = action[4]
        tx.action_total_action_fees = action[5]
        tx.action_result_code = action[6]
        tx.action_result_arg = action[7]
        tx.action_tot_actions = action[8]
        tx.action_spec_actions = action[9]
        tx.action_skipped_actions = action[10]
        tx.action_msgs_created = action[11]
        tx.action_action_list_hash = action[12]
        tx.action_tot_msg_size_cells = action[13][0]
        tx.action_tot_msg_size_bits = action[13][1]

def unpack_messagepack_tx(data: bytes) -> Transaction:
    (tx_data, emulated) = msgpack.unpackb(data, raw=False)
    (tx_hash, account, lt, prev_trans_hash, prev_trans_lt, now, orig_status, end_status, in_msg, out_msgs, total_fees,
     account_state_hash_before, account_state_hash_after, description) = tx_data
    tx = Transaction(
        lt=lt,
        hash=tx_hash,
        prev_trans_hash=prev_trans_hash,
        prev_trans_lt=prev_trans_lt,
        account=account,
        now=now,
        orig_status=account_status_map[orig_status],
        end_status=account_status_map[end_status],
        total_fees=total_fees,
        account_state_hash_before=account_state_hash_before,
        account_state_hash_after=account_state_hash_after,
        emulated=emulated
    )
    fill_tx_description(tx, description)
    tx.messages = [_message_from_tuple(tx, msg, 'out') for msg in out_msgs] + [
        _message_from_tuple(tx, in_msg, 'in')]
    return tx


def deserialize_event(trace_id, packed_transactions_map: dict[str, bytes]) -> Trace:
    edges = []
    transactions = []
    root = packed_transactions_map[trace_id]

    def load_leaf(tx):
        for msg in tx.messages:
            if msg.direction != 'out':
                continue
            child_tx = unpack_messagepack_tx(packed_transactions_map[msg.msg_hash])
            edges.append(TraceEdge(left_tx=tx.hash, right_tx=child_tx.hash, msg_hash=msg.msg_hash, trace_id=trace_id))
            transactions.append(child_tx)
            load_leaf(child_tx)

    root_tx = unpack_messagepack_tx(root)
    transactions.append(root_tx)
    load_leaf(root_tx)
    return Trace(transactions=transactions, edges=edges, trace_id=trace_id, classification_state='unclassified', state='complete')
