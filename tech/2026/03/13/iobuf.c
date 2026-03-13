#include <nolibc/nolibc.h>
#define assert(x) do{ if (!(x)) __builtin_debugtrap(); }while(0)
#define MIN(a,b) ({ __auto_type $a = (a); __auto_type $b = (b); $a < $b ? $a : $b; })
#define MAX(a,b) ({ __auto_type $a = (a); __auto_type $b = (b); $a > $b ? $a : $b; })

#define EMPTY()
#define DEFER(x) x EMPTY()
#define EVAL(...)  EVAL1(EVAL1(EVAL1(__VA_ARGS__)))
#define EVAL1(...) EVAL2(EVAL2(EVAL2(__VA_ARGS__)))
#define EVAL2(...) EVAL3(EVAL3(EVAL3(__VA_ARGS__)))
#define EVAL3(...) EVAL4(EVAL4(EVAL4(__VA_ARGS__)))
#define EVAL4(...) EVAL5(EVAL5(EVAL5(__VA_ARGS__)))
#define EVAL5(...) __VA_ARGS__
#define FOREACH(f,...) __VA_OPT__(EVAL(FOREACH_IMPL(f, __VA_ARGS__)))
#define FOREACH_IMPL(f,x,...) f(x) __VA_OPT__(DEFER(FOREACH_RECURSE) () (f, __VA_ARGS__))
#define FOREACH_RECURSE() FOREACH_IMPL

enum ioerror { IOERR_OK = 0, IOERR_WRITE_FAILED = -1 };
struct iobuf {
    ssize_t cap;
    ssize_t len;
    uint8_t *buf __attribute__((counted_by(cap)));
    int fd;
    enum ioerror err;
};

void Flush(struct iobuf *io)
{
    const uint8_t *buf = io->buf;
    // partial writes are possible on Linux, where write() succeeds but writes fewer bytes than requested.
    while (io->len > 0) {
        ssize_t written = sys_write(io->fd, buf, io->len);
        if (written < 0) {
            io->err = IOERR_WRITE_FAILED;
            break;
        }
        buf += written;
        io->len -= written;
    }
}

void WriteBytes(struct iobuf *io, ssize_t n, const uint8_t bytes[n])
{
    ssize_t written = 0;
    while (io->err == 0 && written < n) {
        ssize_t free = io->cap - io->len;
        ssize_t z = MIN(free, n);
        __builtin_memcpy(io->buf + io->len, bytes, z);
        written += z;
        io->len += z;
        bytes += z;
        if (z < n) Flush(io);
    }
}

void WriteInt(struct iobuf *io, int64_t x)
{
    // longest possible int64 decimal representation is 20 characters (-9223372036854775808)
    uint8_t s[20];
    ssize_t i = 20;
    bool neg = x < 0;
    if (neg) x = -x;
    do s[--i] = '0' + x % 10; while (x /= 10);
    if (neg) s[--i] = '-';
    WriteBytes(io, 20 - i, s + i);
}

void WriteUInt(struct iobuf *io, uint64_t x)
{
    // also 20: no sign character but maximum uint64 is one character longer (18446744073709551615)
    uint8_t s[20];
    ssize_t i = 20;
    do s[--i] = '0' + x % 10; while (x /= 10);
    WriteBytes(io, 20 - i, s + i);
}

void WritePtr(struct iobuf *io, void *p)
{
    uintptr_t x = (uintptr_t)p;
    uint8_t s[16];
    ssize_t i = 16;
    do s[--i] = (x % 16 < 10 ? '0' + x % 16 : 'a' + x % 16 - 10); while (x /= 16);
    WriteBytes(io, 16 - i, s + i);
}

struct stringfmt { ssize_t len; uint8_t *ptr __attribute__((counted_by(len))); };

#define $S(n,s) ((struct stringfmt){.len = (n), .ptr = (s)})
void WriteStringFmt(struct iobuf *io, struct stringfmt fmt)
{
    WriteBytes(io, fmt.len, fmt.ptr);
}

void WriteCString(struct iobuf *io, const char *const s __attribute__((pass_dynamic_object_size(2))))
{
    ssize_t len = __builtin_dynamic_object_size(s, 2);
    assert(len > 0);  // fails if we were passed something other than a string literal
    WriteBytes(io, len - 1 /* trim off \0 */, (const uint8_t *)s);
}

void Fail(void);

#define DISPATCH_WRITE(x) \
    _Generic((x), \
        int8_t: WriteInt, \
        uint8_t: WriteUInt, \
        int16_t: WriteInt, \
        uint16_t: WriteUInt, \
        int32_t: WriteInt, \
        uint32_t: WriteUInt, \
        int64_t: WriteInt, \
        uint64_t: WriteUInt, \
        size_t: WriteUInt, \
        ssize_t: WriteInt, \
        /* if you were to implement floats: \
           float: WriteFloat, \
           double: WriteDouble, */ \
        char *: WriteCString, \
        const char *: WriteCString, \
        struct stringfmt: WriteStringFmt, \
        default: _Generic((x) - (x), ptrdiff_t: WritePtr, default: Fail) \
    )($_io, (x));

#define PutLine(io,...) do{ struct iobuf *$_io = (io); FOREACH(DISPATCH_WRITE, __VA_ARGS__, "\n"); Flush($_io); }while(0)


int main(int argc, const char *argv[argc])
{
    uint8_t buf[256];
    struct iobuf stdout = {.cap = sizeof(buf), .buf = buf, .fd = 1};
    int a = argv[1][0] - '0', b = argv[2][0] - '0';
    const char *world = "world";
    int x = 283;
    PutLine(&stdout, "hello ", world, " x: ", x);
    PutLine(&stdout, a < b ? "ab" : "much longer string");
    return 0;
}
