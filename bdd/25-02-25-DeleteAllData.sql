DO
$$
DECLARE
    r RECORD;
BEGIN
    -- Désactiver temporairement les contraintes FK
    EXECUTE 'SET session_replication_role = replica';

    -- Parcourir toutes les tables du schéma public
    FOR r IN (SELECT tablename 
              FROM pg_tables 
              WHERE schemaname = 'public')
    LOOP
        EXECUTE 'TRUNCATE TABLE public.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;

    -- Réactiver les contraintes
    EXECUTE 'SET session_replication_role = DEFAULT';
END
$$;