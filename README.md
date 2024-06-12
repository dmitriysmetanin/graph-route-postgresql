# graph-route-postgresql

Логика работы алгоритма:
Имеем две таблицы
Таблица m2m связей (ребер в графе) - graph_links (id bigint, node1 bigint, node2 bigint)
Сервисная таблица - graph_service_table (id bigint, p1 bigint, p2 bigint, p3 bigint, p4 bigint, p5 bigint)

1) Выбираем стартовую точку
2) Получаем всех ее соседей, записываем маршрут в первые два столбца в таблице: (p1, p2)
3) Для каждого из соседей - выбираем его соседей, кроме тех точек, которые уже рассматривали, записываем маршрут в столбцы (p1, p2, p3)
4) ... 
5) Получаем таблицу соседей
6) Производим поиск строк, в которых присутствует конечная точка, считаем кол-во значений null, сортируем по убыванию этого кол-ва (меньшая длина пути), выводим первый путь
* - более подробное описание и код в файле create_neighbours.sql

Имеем граф:
<div>
  <img width="297" alt="image" src="https://github.com/dmitriysmetanin/graph-route-postgresql/assets/88580214/c1c77866-30d6-4be8-b495-76bcd00c3237">
</div>

<p>Хотим найти кратчайший путь из точки 6 в точку 7. </p>
<p>Вызываем функцию create_neighbours(6), высчитывая 5 поколений соседей для точки 6.</p>
<p>В результате сервисная таблица наполняется данными:</p>
<div>
  <img width="410" alt="image" src="https://github.com/dmitriysmetanin/graph-route-postgresql/assets/88580214/bb257c47-2e18-4e72-8c50-1295f1d1d9b1">
</div>

<p>Ищем кратчайший маршрут в точку 7 - получаем ответ (6 --> 1 --> 2 --> 7), длина пути = 4</p>
<div>
  <img width="160" alt="image" src="https://github.com/dmitriysmetanin/graph-route-postgresql/assets/88580214/e10825e8-e45f-4e3b-afa5-528b3a465639">
</div>

