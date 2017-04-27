create or replace function notify_change_shadow() returns event_trigger as $$

declare obj record;

begin
    raise notice 'ela tg_op: %, tg_table_name: %', tg_op, tg_table_name;
    if (tg_op = 'delete') then 
        select pg_notify('pg_shadow_' || tg_op);
        -- return old;
    else
        select pg_notify('pg_shadow_' || tg_op);
        -- return new;
    end if;
    FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
    LOOP
        RAISE NOTICE '% dropped object: % %.% %',
                     tg_tag,
                     obj.object_type,
                     obj.schema_name,
                     obj.object_name,
                     obj.object_identity;
    END LOOP;
end;

$$ language plpgsql;
