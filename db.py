import psycopg2
import psycopg2.extras

def connect():
  conn = psycopg2.connect(
    dbname = '',
    user = '',
    host = 'localhost',
    password = '',
    port = 5432,
    cursor_factory = psycopg2.extras.NamedTupleCursor
  )
  conn.autocommit = True
  return conn
