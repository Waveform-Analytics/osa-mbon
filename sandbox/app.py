"""_Dash Application - BioSound-MBON_
"""

from dash import Dash, html, dcc, callback, Output, Input

import pandas as pd
import plotly.express as px
import dash_bootstrap_components as dbc

# import plotly.graph_objects as go
# from plotly.subplots import make_subplots

# from sklearn.preprocessing import MinMaxScaler
# import numpy as np
# from scipy.interpolate import interp1d


# Import the acoustic indices
FWRI_INDICES = "data/FWRI_Marathon/Native_Duration_30sec/2020_02/Acoustic_Indices.csv"
df = pd.read_csv(FWRI_INDICES)

# Convert to date strings to datetime
df['datetime'] = pd.to_datetime(df['Date'])
df.sort_values('datetime').head(5)

# Initialize the app - incorporate a Dash Bootstrap theme
external_stylesheets = [dbc.themes.CERULEAN]
app = Dash(__name__, external_stylesheets=external_stylesheets)

# App layout
app.layout = dbc.Container([
    dbc.Row([
        html.Div('My First App with Data, Graph, and Controls', className="text-primary text-center fs-3")
    ]),

    dbc.Row([
        dbc.RadioItems(options=[{"label": x, "value": x} for x in ['pop', 'lifeExp', 'gdpPercap']],
                       value='lifeExp',
                       inline=True,
                       id='radio-buttons-final')
    ]),

    dbc.Row([
        dbc.Col([
            dash_table.DataTable(data=df.to_dict('records'), page_size=12, style_table={'overflowX': 'auto'})
        ], width=6),

        dbc.Col([
            dcc.Graph(figure={}, id='my-first-graph-final')
        ], width=6),
    ]),

], fluid=True)

# # App layout
# app.layout = html.Div([
#     html.Div(children='Quick plot'),
#     html.Hr(),
#     dcc.RadioItems(options=['EPS_SKEW', 'ACI', 'NDSI', 'rBA'], value='ACI', id="idx-radio-select"),
#     dcc.Graph(figure={}, id="line-graph"),
# ])

# Add controls to build the interaction
@callback(
    Output(component_id='line-graph', component_property='figure'),
    Input(component_id='idx-radio-select', component_property='value')
)
def update_graph(col_chosen):
    fig = px.line(df, x="datetime", y=col_chosen)
    return fig

if __name__ == '__main__':
    app.run(debug=True)