import asyncio
import websockets
import random
import time

COLORS = ['orange', 'brown', 'blue', 'green', 'grey', 'red', 'yellow', 'white']


async def hello(websocket, path):
    time.sleep(1)
    bodies = []
    for _ in range(10):
        x = random.randint(0, 1300)
        y = random.randint(0, 700)
        color = random.sample(COLORS, 1)[0]
        bodies.append({'position': {'x': x, 'y': y}, 'color': color})
    message = str(bodies).replace("'", '"')
    await websocket.send(message)
    print(f"> {message}")


start_server = websockets.serve(hello, 'localhost', 8765)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
