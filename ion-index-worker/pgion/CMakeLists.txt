cmake_minimum_required(VERSION 3.10)
project(pgion)

find_package(PostgreSQL REQUIRED)
add_postgresql_extension(pgion
  VERSION 0.1
  SOURCES pgion.c
  SCRIPTS pgion--0.1.sql
  REGRESS basic)

enable_testing()
