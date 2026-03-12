# Resotre database from dump

* Make backup: 

        docker run --rm -it --network <network> -v `pwd`/private/dump:/output postgres:14 bash -c "pg_dump --format=custom -h postgres -U postgres --file=/output/index.db ion_index --verbose"

* Restore backup: 
        
        docker run --rm -it --network <network> -v `pwd`/private/dump:/input postgres:14 bash -c "pg_restore -h postgres -U postgres --dbname=ion_index --clean --no-owner /input/index.db --verbose"

        * Remove flag `--clean` if database ion_index not exists.
* Find your network: `docker network ls`.
