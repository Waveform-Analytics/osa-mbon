import marimo

__generated_with = "0.11.2"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    import duckdb
    return duckdb, mo


@app.cell
def _():
    data_file_name = "../shiny/data/mbon11.duckdb"
    return (data_file_name,)


@app.cell
def _(data_file_name, duckdb):
    # Connect to the duckdb file
    conn = duckdb.connect(data_file_name)
    return (conn,)


@app.cell
def _(conn):
    # Run a query to view available tables
    tables = conn.execute("SHOW TABLES").fetchall()
    print("Tables in database: ", tables)
    return (tables,)


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
