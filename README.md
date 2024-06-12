# graph-route-postgresql

<h2>Предисловие:</h2>
Мне казалась довольно непонятной тема с рекурсией, я решил разобрать ее и попробовать что-то интересное сделать.
У меня была таблица с 12млн. пользователями ВК и ~600к записями в m2m таблице дружеских связей, которые я когда то выгрузил.  Я решил реализовать алгоритм поиска кратчайшего пути по друзьям. Сначала начал писать рекурсивный запрос, примеров которых было много в интернете, на малом наборе данных (граф из 10 узлов). Алгоритмы работали до того момента, пока в графе не появлялся цикл. А ведь в дружеских связях это неизбежно. Я не знал, как решить и решил воспользоваться известной социологической теорией. Согласно ей, каждый человек связан с другим в цепочку не более из 6 человек (теория 6 рукопожатий).
Я прочитал, что Facebook опроверг эту теорию и реальное кол-во в соцсети - 3.57. Написал скрипт, который формировал данные о 5  поколениях друзей для любого пользователя в моей базе, после чего между от этого пользователя можно найти кратчайший маршрут к любому его другу.

<h2>Что мы имеем?</h2>
<p>Имеем две таблицы</p>
<p>Таблица m2m связей (ребер в графе) - graph_links (id bigint, node1 bigint, node2 bigint)</p>
<p>Сервисная таблица - graph_service_table (id bigint, p1 bigint, p2 bigint, p3 bigint, p4 bigint, p5 bigint)</p>

<h2>Задача</h2>
<p>Необходимо найти кратчайший маршрут из точки А в точку Б. 

<h2>Логика работы алгоритма:</h2>

1) Выбираем стартовую точку
2) Получаем всех ее соседей, записываем маршрут в первые два столбца в таблице: (p1, p2)
3) Для каждого из соседей - выбираем его соседей, кроме тех точек, которые уже рассматривали, записываем маршрут в столбцы (p1, p2, p3)
4) ... 
5) Получаем таблицу соседей
6) Производим поиск строк, в которых присутствует конечная точка, считаем кол-во значений null, сортируем по убыванию этого кол-ва (меньшая длина пути), выводим первый путь

<h2>Пример</h2>

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

