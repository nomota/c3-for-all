# Networking

C3 networking provides TCP, UDP, Socket, URL, and inetaddr. All are in `std::net` moduke.

### InetAddress

These utility functions are supported.

```c3
import std::net;
Allocator allocx;

uint? ip = net::ipv4toint(String s);
String? ipstr = net::int_to_ipv4(uint val, allocx);

InetAddress inetaddr;
InetAddress? inetaddr = net::ipv6_from_str(String s);
InetAddress? inetaddr = net::ipv4_from_str(String s);

String str = inetaddr.to_string(allocx);
String str = inetaddr.to_tstring();
bool b = inetaddr.is_loopback();
bool b = inetaddr.is_any_local();
bool b = inetaddr.is_link_local();
bool b = inetaddr.is_site_local();
bool b = inetaddr.is_multicast();
bool b = inetaddr.is_multicast_global();
bool b = inetaddr.is_multicast_node_local();
bool b = inetaddr.is_multicast_site_local();
bool b = inetaddr.is_multicast_org_local();
bool b = inetaddr.is_multicast_link_local();

AddrInfo*? ai = net::addrinfo(String host, uint port, AIFamily ai_family, AISockType ai_socktype);
// ai_family = AF_INET|AF_INET6
// ai_socktype = SOCK_STREAM|SOCK_DGRAM
```
### URL

These functions are available for URL processing.

```c3
import std::net::url;

struct Url
{
    String scheme;
    String host;
    uint   port;
    String username;
    String password;
    String path;
    String query;
    String fragment;

    Allocator allocator;
}

Allocator allocx;
Url url;

Url? url = url::tparse(String url_str);
Url? url = url::parse(allocx, String url_str);
String url_str = url.to_string(allocx);

alias UrlQueryValueList = List{String};
struct UrlQueryValues
{
    inline HashMap{String, UrlQueryValueList} map;
    UrlQueryValueList key_order;
}
UrlQueryValues qvs;

UrlQueryValues qvs = url::parse_query_to_temp(String query);
UrlQueryValues qvs = url::parse_query(allocx, String query);
UrlQueryValues* qvs = qvs.add(String key, String value);

void qvs.free();
void url.free();
```

### Sockets

To start a socket connection, following functions are used.

```c3
import std::net;

TcpSocket? sock = tcp::connect(String host, uint port, Duration timeout = time::DURATION_ZERO, SocketOption... options, IpProtocol ip_protocol = UNSPECIFIED);
TcpSocket? sock = tcp::connect_async(String host, uint port, SocketOption... options, IpProtocol ip_protocol = UNSPECIFIED);
TcpSocket? sock = tcp::connect_to(AddrInfo* ai, SocketOption... options);

TcpServerSocket? server_sock = tcp::listen(String host, uint port, uint backlog, SocketOption... options, IpProtocol ip_protocol = UNSPECIFIED);

// after creating server socket, call following option
void server_sock.set_reuseaddr(true);

TcpSocket? sock = tcp::accept(TcpServerSocket* server_sock);
TcpServerSocket? sock = tcp::listen_to(AddrInfo* ai, uint backlog, SocketOption... options);

// after 

UdpSocket? sock = udp::connect(String host, uint port, SocketOption... options, IpProtocol ip_protocol = UNSPECIFIED);
UdpSocket? sock = udp::connect_to(AddrInfo* ai, SocketOption... options)
UdpSocket? sock = udp::connect_async(String host, uint port, SocketOption... options, IpProtocol ip_protocol = UNSPECIFIED);
UdpSocket? sock = udp::connect_async_to(AddrInfo* ai, SocketOption... options)

Socket net::new_socket(fd, AddrInfo* ai);

// options = REUSEADDR|KEEPALIVE|O_NONEBLOCK
// ip_protocol = IPPROTO_IP

void sock.close();
```

Setting socket options.

```c3
Socket sock;

void? sock.set_keepalive(bool value);
void? sock.set_option(KEEPALIVE, value);
void? sock.set_reuseaddr(bool value)
void? sock.set_option(REUSEADDR, value);
void? sock_non_blocking();

/*.
on POSIX systems
NativeSocket socket_fd = sock.sock;
os::TimeVal timeout = { .tv_sec = 5, .tv_usec = 0 };
// Receive timeout
os::setsockopt(socket_fd, os::SOL_SOCKET, os::SO_RCVTIMEO, &timeout, usz(sizeof(os::TimeVal)));
// Send timeout
os::setsockopt(socket_fd, os::SOL_SOCKET, os::SO_SNDTIMEO, &timeout, usz(sizeof(os::TimeVal)));

       /* int errcode = os::setsockopt(self.sock, os::SOL_SOCKET, option.value, &flag, CInt.sizeof);*/
*/
```

Reading and writing on sockets are like this.

```c3
usz? n = sock.write(char[] buffer);
usz? n = sock.read(char[] buffer);
```

### Non-blocking async I/O

Doing non-blocking async I/O can be done like this. 

```c3
// Suppose you have multiple sockets with .set NONEBLOCK
void sock.set_option(O_NONEBLOCK, true);

Sock[] socks;

Poll[socks.len] polls;
for (i, s: socks) {
    polls[i].socket = s;
    polls[i].events = SUBSCRIBE_READ|SUBSCRIBE_WRITE;
}

ulong? n = net::poll_ms(Poll[] polls, long timeout_ms);

for(usz i = 0; i < n; i++) {
    Socket sock = polls[i].sock;
    PollEvent e = polls[i].revents;
    if (e & POLL_EVENT_READ) { // read ready
        // do read on sock
        // usz? n = sock.read(buffer[]);
    }
    if (e & POLL_EVENT_WRITE) { // write ready
        // do write on sock
        // usz? n = sock.write(buffer[]);
    }
    if (e & (POLL_EVENT_ERROR | POLL_EVENT_DISCONNECT | POLL_EVENT_INVALID)) { // socke is error
        // do error handling on sock
        (void) sock.close();
        // remove sock from polls
    }
}
```

* Note: `net::accept()` of non-blocking server socket returns a non-blocking socket.

* Note: If `net::connect()` of non-blocking socket is successfully connected, `POLL_EVENT_READ` event gets fired.

Back to [Table of Contents](0.table-of-contents.md)
