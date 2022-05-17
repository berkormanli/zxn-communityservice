# zxn-communityservice
QBCore powered community service resource (a very basic one.)

# License

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>

## Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [ghmattimysql] or [oxmysql](https://github.com/overextended/oxmysql)

## Demo
Not yet, probably never.

## Features
- 2 types of work to do. Brooming and trimming
- Command based resource, drag&drop and ready to go.
-

## Installation
Insert this to your database
```
CREATE TABLE IF NOT EXISTS `communityservice` (
  `citizenid` varchar(255) NOT NULL,
  `actions_remaining` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```
