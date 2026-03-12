#pragma once
#include <unordered_map>
#include <unordered_set>
#include <vector>
#include <string>
#include "td/actor/actor.h"
#include "ion/ion-types.h"
#include "IndexData.h"

struct BlockIdHasher {
    std::size_t operator()(const ion::BlockId& k) const {
        std::size_t seed = 0;
        seed ^= std::hash<ion::WorkchainId>()(k.workchain) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
        seed ^= std::hash<ion::ShardId>()(k.shard) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
        seed ^= std::hash<ion::BlockSeqno>()(k.seqno) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
        return seed;
    }
};

struct BlockIdEq {
    bool operator()(const ion::BlockId& a, const ion::BlockId& b) const {
        return a.workchain == b.workchain && a.shard == b.shard && a.seqno == b.seqno;
    }
};

struct PendingConfirmedBlock {
    ion::BlockIdExt block_id_ext;
    std::unordered_set<td::Bits256> trace_hashes;
};

struct FinalizedBlockTraces {
    ion::BlockIdExt block_id_ext;
    std::unordered_set<td::Bits256> trace_hashes;
};

struct ShardIdHasher {
    std::size_t operator()(const ion::ShardIdFull& s) const {
        return std::hash<ion::WorkchainId>()(s.workchain) ^ (std::hash<ion::ShardId>()(s.shard) << 1);
    }
};

struct ShardIdEq {
    bool operator()(const ion::ShardIdFull& a, const ion::ShardIdFull& b) const {
        return a.workchain == b.workchain && a.shard == b.shard;
    }
};

struct PendingInvalidation {
    ion::BlockSeqno origin_seqno;
    std::unordered_set<td::Bits256> trace_hashes;
};

class InvalidatedTraceTracker : public td::actor::Actor {
  private:
    std::string redis_dsn_;
    std::unordered_map<ion::BlockId, std::vector<PendingConfirmedBlock>, BlockIdHasher, BlockIdEq> pending_confirmed_blocks_;
    std::unordered_map<ion::BlockId, FinalizedBlockTraces, BlockIdHasher, BlockIdEq> finalized_block_traces_;
    std::unordered_map<ion::ShardIdFull, PendingInvalidation, ShardIdHasher, ShardIdEq> deferred_invalidations_;

    void confirmed_block_discarded(const ion::BlockIdExt& pending_block, const ion::BlockIdExt& finalized_block);
    void publish_invalidated_traces(std::vector<td::Bits256> traces);
    void process_finalized_block(const ion::BlockId& block_id);

  public:
    explicit InvalidatedTraceTracker(std::string redis_dsn) : redis_dsn_(std::move(redis_dsn)) {}

    void register_pending_block(ion::BlockIdExt block_id_ext);
    void add_confirmed_trace(ion::BlockIdExt block_id_ext, td::Bits256 ext_in_hash_norm);
    void add_finalized_trace(ion::BlockIdExt block_id_ext, td::Bits256 ext_in_hash_norm);
    void finalized_mc_block_emulated(std::vector<ion::BlockId> block_ids);
};
