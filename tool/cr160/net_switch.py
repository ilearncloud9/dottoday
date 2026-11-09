"""CR-160 test-only network switch: a TCP pass-through to the local Supabase
API (127.0.0.1:54321) on 127.0.0.1:54331 that the app under test talks to,
plus a control endpoint on 127.0.0.1:54332 (/off, /on, /state).
Off = every open connection is cut and new ones are closed at once, so the
app's sync gateway sees a real network failure. Local only.
"""
import asyncio
import sys

UP = ('127.0.0.1', 54321)
online = True
conns = set()


async def pipe(r, w):
    try:
        while True:
            data = await r.read(65536)
            if not data:
                break
            w.write(data)
            await w.drain()
    except Exception:
        pass
    finally:
        try:
            w.close()
        except Exception:
            pass


async def handle(cr, cw):
    if not online:
        cw.close()
        return
    try:
        ur, uw = await asyncio.open_connection(*UP)
    except Exception:
        cw.close()
        return
    pair = (cw, uw)
    conns.add(pair)
    try:
        await asyncio.gather(pipe(cr, uw), pipe(ur, cw))
    finally:
        conns.discard(pair)


async def control(cr, cw):
    global online
    line = (await cr.readline()).decode(errors='ignore')
    while (await cr.readline()) not in (b'\r\n', b'\n', b''):
        pass
    path = line.split(' ')[1] if ' ' in line else '/'
    if line.startswith('OPTIONS'):
        cw.write(b'HTTP/1.1 204 No Content\r\nAccess-Control-Allow-Origin: *\r\n'
                 b'Access-Control-Allow-Headers: *\r\nAccess-Control-Allow-Methods: GET\r\n'
                 b'Content-Length: 0\r\nConnection: close\r\n\r\n')
        await cw.drain()
        cw.close()
        return
    leaf = path.split('?')[0].rstrip('/').split('/')[-1]
    if leaf == 'off':
        online = False
        for a, b in list(conns):
            for w in (a, b):
                try:
                    w.transport.abort()
                except Exception:
                    pass
        conns.clear()
    elif leaf == 'on':
        online = True
    state = 'online' if online else 'offline'
    body = ('[{"state":"%s"}]' % state).encode()
    print(f'control {path.strip()} -> {state}', flush=True)
    cw.write(b'HTTP/1.1 200 OK\r\nAccess-Control-Allow-Origin: *\r\n'
             b'Content-Type: application/json\r\nContent-Length: ' +
             str(len(body)).encode() + b'\r\nConnection: close\r\n\r\n' + body)
    await cw.drain()
    cw.close()


async def main():
    s1 = await asyncio.start_server(handle, '127.0.0.1', 54331)
    s2 = await asyncio.start_server(control, '127.0.0.1', 54332)
    print('proxy up 54331 -> 54321, control 54332', flush=True)
    async with s1, s2:
        await asyncio.gather(s1.serve_forever(), s2.serve_forever())


if __name__ == '__main__':
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        sys.exit(0)
