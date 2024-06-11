create or replace function create_friends(starting_point_id bigint)
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
