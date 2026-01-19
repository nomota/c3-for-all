# Upgrading std::net

I was translating my network code and found C3's current `std::net` has following issues and I corrected as follows.

1. Network related stuff is placed in `libc` and `std::os`. Very small pieces. These need to be properly placed in `std::net`. => Remove them, move to `std::net`

2. `std::net` impotrs `libc` and `std::os` due to those tiny pieces. => Remove importing `libc` and `std::os`, from all files in std/net.

3. In `libc.a` a lot of network related functions. Best is to give `extern` bridge for all of them, but... I added following functions.
  * getnameinfo(), gethostbyaddr(), gethostbyname()
  * close(), recvfrom(), sendto()
  * inet_ntop(), inet_pton()
  * htons(), ntohs(), getpeerbyname()
  * so far, less than 20 functions are mapped to extern.
  * There are 50+ network related functions in libc.a

4. Added required structs for these functions, in std/net/os/common.c3

5.Mergerd ws2def.c3 to wsa.c3. Move it from std/os/win32 to std/net/win32. Rename module from std::io::win32 to std::net::win32.

6. Correct Socket.close(). Current close() calls int_fd.close() which is meaningless. => corrected as close(int_fd) style.

Actually I haven't touched anything, yet, but just made a patch instruction for manual update, as follows.


```c3
// * std/libc/os/posix.c3
// (remove these lines)
// move to std/net/os/posix.c3

const CInt SHUT_RD = 0;
const CInt SHUT_WR = 1;
const CInt SHUT_RDWR = 2;
extern fn CInt shutdown(Fd sockfd, CInt how);

extern fn isz recv(Fd socket, void *buffer, usz length, CInt flags);
extern fn isz send(Fd socket, void *buffer, usz length, CInt flags);




// * std/libc/os/win32.c3
// (remove these lines)
// move to std/net/os/win32.c3

extern fn int recv(Win32_SOCKET s, void* buf, int len, int flags);
extern fn int send(Win32_SOCKET s, void* buf, int len, int flags);

const CInt SD_RECEIVE = 0;
const CInt SD_SEND = 1;
const CInt SD_BOTH = 2;
extern fn CInt shutdown(Win32_SOCKET s, CInt how);



// * std/os/linux/linux.c3
// (remove these)
// these are not very necessary. 
// these are not used anywhere in std library, so far

import std::net::os; // cyclic reference, remove

extern fn char** inet_ntop(int, void*, char*, Socklen_t);
extern fn uint htonl(uint hostlong);
extern fn ushort htons(ushort hostshort);
extern fn uint ntohl(uint netlong);
extern fn ushort ntohs(ushort netshort);


// * std/os/win32/windef.c3
// remove these
// they are duplicated in ws2def.c3

struct Win32_WSABUF 
{
        Win32_ULONG len;
        Win32_CHAR* buf;
}

struct Win32_SOCKADDR 
{
   Win32_USHORT sa_family;
   Win32_CHAR[14]* sa_data;
}

alias Win32_PWSABUF = Win32_WSABUF*;
alias Win32_LPWSABUF = Win32_WSABUF*;

alias Win32_PSOCKADDR = Win32_SOCKADDR*;
alias Win32_LPSOCKADDR = Win32_SOCKADDR*;



// * std/os/win32/ws2def.c3
// delete this file
// copy the content of this file
// to the beginning of wsa.c3



// * std/os/win32/wsa.c3
// delete this file
// move to std/net/os/wsa.c3



// * std/net/os/wsa.c3

   replace all
      std::os::win32 => std::net::win32


// * std/net/os/posix.c3
// (add following lines)

extern CInt close(NativeSocket fd);

const CInt SHUT_RD = 0;
const CInt SHUT_WR = 1;
const CInt SHUT_RDWR = 2;
extern fn CInt shutdown(NativeSocket sockfd, CInt how);

extern fn isz recv(NativeSocket socket, void *buffer, usz length, CInt flags);
extern fn isz send(NativeSocket socket, void *buffer, usz length, CInt flags);

extern fn isz sendto(NativeSocket sockfd, void* buf, usz len, CInt flags, SockAddrPtr dest_addr, Socklen_t addrlen);
extern fn isz recvfrom(NativeSocket sockfd, void* buf, usz len, CInt flags, SockAddrPtr src_addr, Socklen_t* addrlen);

// address conversion
extern char* inet_ntop(CInt af, void* sin_addr, char* outbuf, CInt outbuflen);
extern CInt inet_pton(CInt af, char* ip_str, void* sin_addr);
extern ushort ntohs(ushort sin_port);
extern ushort htons(ushort sin_port);

// DNS lookup
extern HostEnt* gethostbyname(char *name); // unsafe
extern HostEnt *gethostbyaddr(char *addr, CInt len, CInt type); // unsafe

extern CInt getpeername(NativeSocket s, SockAddr *name, CInt *namelen);






// * std/net/os/win32.c3
// (add following lines)

extern CInt close(NativeSocket fd);

const CInt SD_RECEIVE = 0;
const CInt SD_SEND = 1;
const CInt SD_BOTH = 2;
extern fn CInt shutdown(NativeSocket s, CInt how);
extern fn CInt recv(NativeSocket s, char* buf, CInt len, CInt flags);
extern fn CInt send(NativeSocket s, char* buf, CInt len, CInt flags);

extern fn CInt sendto(NativeSocket s, char* buf, CInt len, CInt flags, SockAddrPtr to, CInt tolen);
extern fn CInt recvfrom(NativeSocket s, char* buf, CInt len, CInt flags, SockAddrPtr from, CInt* fromlen);

// address conversion
extern char* inet_ntop(CInt af, void* sin_addr, char* outbuf, CInt outbuflen);
extern CInt inet_pton(CInt af, char* ip_str, void* sin_addr);
extern ushort ntohs(ushort sin_port);
extern ushort htons(ushort sin_port);

// DNS lookup
extern HostEnt* gethostbyname(char *name); // unsafe
extern HostEnt *gethostbyaddr(char *addr, CInt len, CInt type); // unsafe

extern CInt getpeername(NativeSocket s, SockAddr *name, CInt *namelen);





// * std/net/socket.c3 (update these)

  remove 
    import libc;
    import std::os;
    
  add
    import std::net::os;
    import std::net::win32 @if(env::WIN32);
    
  replace all
    libc::recv => os::recv
    libc::send => os::send
    libc::shutdown => os::shutdown
    how.nativevalue => how

remove this
 
enum SocketShutdownHow : (CInt native_value)
{
        RECEIVE = env::WIN32 ??? libc::SD_RECEIVE : libc::SHUT_RD,
        SEND = env::WIN32 ??? libc::SD_SEND : libc::SHUT_WR,
        BOTH = env::WIN32 ??? libc::SD_BOTH : libc::SHUT_RDWR,
}

add this

enum SocketShutdownHow : (CInt)
{
        RECEIVE,
        SEND,
        BOTH,
}

remove this

fn void? Socket.close(&self) @inline @dynamic
{
        self.sock.close()!;
}


add this 

fn void? Socket.close(&self) @inline @dynamic
{
        if (os::close(self.sock) < 0)
        {
                return os::socket_error()?;
        }
}




// * std/net/socket_private.c3

remove 
    import libc, std::os;
    
add 
    import std::net::net;
  
  
  
    

// * std/net/os/android.c3
// * std/net/os/darwin.c3
// * std/net/os/linux.c3
// * std/net/os/netbsd.c3
// * std/net/os/openbsd.c3
for all above files, remove
    import libc;
    
// * std/net/os/posix.c3
remove 
    import libc;

// * std/net/os/win32.c3
remove
    import libc;
    import std::os;
replace
    std::os::win32 => std::net:win32
    
// * std/net/tcp.c3
remove 
    import libc
replace 
    std::os::win32 => std::net::win32
    



// * std/net/os/common.c3

add

union SockAddr {
    struct { // ipv4
        short sin_family;
        ushort sin_port;
        char[4] sin_addr; // InAddr
        char[8] sin_zero;
    }
    
    struct { // ipv6
        short sin6_family;
        ushort sin6_port;
        ulong sin6_flowinfo;
        char[16] sin6_addr; // In6Addr
        ulong sin6_scope_id;
    }
}

union InAddr {
    char[4] ipv4;
    char[16] ipv6;
}

struct HostEnt {
    char *h_name;
    char** h_aliases;
    short h_addrtype; // AF_INET | AF_INET6
    short h_length; // 4 or 16
    InAddr** h_addrs;
}

remove
    typedef SockAddrPtr = void*;
    
add
    typedef SockAddrPtr = SockAddr*;
    
add (after getaddrinfo())

extern CInt getnameinfo(SockAddr *sa, Socklen_t salen, char *hostbuf, usz hostlen, char *servbuf, usz servlen, CInt flags);

```

Anybody do apply this manually and make PR on behalf of me?

Why don't I do myself?

I don't have any pc with me. I'm on a Galaxy phone. I have no testing environment.

 