"""
Таблица m2m связей - graph_links (id bigint, node1 bigint, node2 bigint)
Сервисная таблица - graph_service_table (id bigint, p1 bigint, p2 bigint, p3 bigint, p4 bigint, p5 bigint)

Алгоритм не является оптимальным. 
Как можно улучшить:
    - добавить в функцию конечное значение (id 2-го пользователя или 2-й точки);
    - после каждой итерации i-й проверять, присутствует ли строка с конечным значением в i-ом столбце;
    - если присутствует, то это кратчайший путь и нет смысла искать соседей дальше.

На графе из малого количества узлов все работает прекрасно, однако в случае 12млн. пользователей ВК и 600к дружеских связей вычисления слишком долгие.
Как можно улучшить:
    - составной btree-индекс на столбцах (node1, node2) m2m таблицы дружеских связей;
    - btree-индекс на столбцах node1 и node2 (отдельно для каждого) таблицы graph_links с низким fillfactor'ом;
"""

create or replace function create_neighbours(starting_point_id bigint)
    returns bool
    language plpgsql
as
$$
declare

begin
    insert into graph_service_table (p1, p2)
    select node1, node2
    from graph_links
    where node1 = starting_point_id
    union
    select node2, node1
    from graph_links
    where node2 = starting_point_id;


    insert into graph_service_table(p1, p2, p3)
    select p1,
           p2,
           (select case
                       when graph_links.node1 != p2 then graph_links.node1
                       else graph_links.node2 end) p3
    from graph_service_table
             inner join graph_links
                        on (graph_links.node1 = graph_service_table.p2 and graph_links.node2 != graph_service_table.p1)
                            or
                           (graph_links.node2 = graph_service_table.p2 and graph_links.node1 != graph_service_table.p1);

    insert into graph_service_table(p1, p2, p3, p4)
    select p1,
           p2,
           p3,
           (select case
                       when graph_links.node1 != p3 then graph_links.node1
                       else graph_links.node2 end) p4
    from graph_service_table
             inner join graph_links
                        on (graph_links.node1 = graph_service_table.p3 and graph_links.node2 != graph_service_table.p2)
                            or
                           (graph_links.node2 = graph_service_table.p3 and graph_links.node1 != graph_service_table.p2);

    insert into graph_service_table(p1, p2, p3, p4, p5)
    select p1,
           p2,
           p3,
           p4,
           (select case
                       when graph_links.node1 != p4 then graph_links.node1
                       else graph_links.node2 end) p5
    from graph_service_table
             inner join graph_links
                        on (graph_links.node1 = graph_service_table.p4 and graph_links.node2 != graph_service_table.p3)
                            or
                           (graph_links.node2 = graph_service_table.p4 and graph_links.node1 != graph_service_table.p3);


    return True;
end;
$$;
