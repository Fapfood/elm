import asyncio
import websockets
import random
import time

COLORS = ['orange', 'brown', 'blue', 'green', 'grey', 'red', 'yellow', 'white']
KINDS = ['circle', 'box', 'triangle', 'human']


async def hello(websocket, path):
    time.sleep(1)
    configuration = {'config': [{'name': 'box', 'parts': [{'kind': 'r', 'value': [0, 0, 5, 5]}]},
                                {'name': 'circle', 'parts': [{'kind': 'c', 'value': [0, 0, 5]}]},
                                {'name': 'triangle', 'parts': [{'kind': 'p', 'value': [-5, 5, 5, 5, 0, -5]}]},
                                {'name': 'human',
                                 'parts': [{'kind': 'p', 'value': [-5, 5, 5, 5, 0, -5]}, {'kind': 'c', 'value': [0, -7, 4]}]},
                                ],
                     'width': 1300,
                     'height': 700}
    message = str(configuration).replace("'", '"')
    await websocket.send(message)
    print(f"> {message}")
    time.sleep(1)
    bodies = []
    for _ in range(10):
        x = random.randint(0, 1300)
        y = random.randint(0, 700)
        color = random.sample(COLORS, 1)[0]
        kind = random.sample(KINDS, 1)[0]
        bodies.append({'position': {'x': x, 'y': y}, 'color': color, 'kind': kind, 'rotation': 30})
    d = {'bodies': bodies}
    message = str(d).replace("'", '"')
    await websocket.send(message)
    print(f"> {message}")


start_server = websockets.serve(hello, 'localhost', 8765)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
