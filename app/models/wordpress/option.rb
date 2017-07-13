# +--------------+---------------------+------+-----+---------+----------------+
# | Field        | Type                | Null | Key | Default | Extra          |
# +--------------+---------------------+------+-----+---------+----------------+
# | option_id    | bigint(20) unsigned | NO   | PRI | NULL    | auto_increment |
# | option_name  | varchar(64)         | NO   | UNI |         |                |
# | option_value | longtext            | NO   |     | NULL    |                |
# | autoload     | varchar(20)         | NO   | MUL | yes     |                |
# +--------------+---------------------+------+-----+---------+----------------+
module Wordpress
  class Option < WpBase
    self.table_name = self.prefix_table_name("options")
    self.primary_key = 'option_id'
  end
end
