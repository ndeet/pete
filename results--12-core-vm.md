### Detailed results: VM 12 cores, 32gb RAM ###

Hardware:    
App VM: [Digitalocean VM 12-cores, 32gb RAM](https://www.digitalocean.com/pricing)      
Benchmark VM: Digitalocean VM 4-cores, 8gb RAM
Network: 1 Gb/s on digitalocean, wrk instance with 4 cores and 8gb ram even on digitalocean with 1 Gb/s to really squeeze the server out    
OS: Debian Jessie 8.2 
Phoenix stack: Erlang 18.2.1 (SMP + hipe enabled), Elixir 1.2.0, Phoenix 1.1.0   
PHP Stack: PHP 5.6.14-0-deb8u1, PHP 7.0.1 (self compiled), as PHP-FPM, OPcache enabled, Nginx 1.6.2    
(configs optimized for big machines ```configs/big-machine``` directory)

First we use similar ```wrk``` params with 100 connections, below we will throw 400 connections on the instance with suprising results.    
```
# ./wrk -t12 -c100 -d60s --timeout 1000   
```

#### Phoenix Framework (Elixir) ####
Erlang OTP 18.2.1, Elixir 1.2.0, Phoenix 1.1.0    
System load: 6-7
```
# ./wrk -t12 -c100 -d60s --timeout 1000 http://pete-phoenix.do:4001/gallery
Running 1m test @ http://pete-phoenix.do:4001/gallery
  12 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    31.29ms    7.04ms  80.08ms   70.65%
    Req/Sec   256.62     39.74   430.00     68.68%
  184185 requests in 1.00m, 353.80MB read
Requests/sec:   3065.37
Transfer/sec:      5.89MB
```
As we see below these are not the results I was expecting. The VM is not fully used by Erlang/Phoenix. 
The load of the system is only 6 altough PHP generates a load of 18 to 22 on the same system. So either Erlang/Beam is 
the bottleneck or some network connectivity? But against a connectivity issue speaks that Phalcon below gets a 
~15 MB transfer/sec and as shown above Phoenix only ~6 MB transfer/sec (therefore I doubt the 1 Gb/s link is the problem).

I tried to play (I'm really clueless which erlang vm options to use) with some erlang vm args 
and was able to gain approx 10% throughput to ~3300 req/s but the load of the system still does
not go above 8 and it seems that it still does not use all ressources.

If anybody with good Erlang/Beam or cowboy webserver knowledge can give some hint's what to
try I would be thankful :)

I tried some options from great riak tuning docs: http://docs.basho.com/riak/latest/ops/tuning/erlang/
(rlimit, os scheduler, some erlang settings) a minimal gain (3300 req/s) I was able to do with this command 
(no idea if that's the correct place and syntax):    
```
# MIX_ENV=prod PORT=4001 elixir --erl "+Q 1000000 +zdbbl 64000 +swt high" -S mix phoenix.server   
```

But as mentioned above, this is not really a win, the load is still only 8 - which is great btw. but
it feels like there is a lot of potential lost and Phoenix does not take the crown. If we approximate by load
Phoenix may be able to do ~10.000 req/s?

#### Slim Framework (PHP) ####
PHP 5.6.14-0+deb8u1 as FPM, Nginx 1.6.2.     
System load: 20
```
# ./wrk -t12 -c100 -d60s --timeout 1000 http://pete-slim.do/gallery
Running 1m test @ http://pete-slim.do/gallery
  12 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    28.11ms    6.80ms 160.06ms   84.15%
    Req/Sec   286.33     41.54   373.00     83.96%
  205490 requests in 1.00m, 360.58MB read
Requests/sec:   3419.78
Transfer/sec:      6.00MB
```

PHP 7.0.1        
System load: 22
```
# ./wrk -t12 -c100 -d60s --timeout 1000 http://pete-slim.do/gallery
Running 1m test @ http://pete-slim.do/gallery
  12 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    13.44ms    3.70ms 140.91ms   84.35%
    Req/Sec   599.78     72.62   780.00     75.94%
  430288 requests in 1.00m, 765.29MB read
Requests/sec:   7162.05
Transfer/sec:     12.74MB
```
This is a really great improvement from PHP 5.6 to PHP 7 and it is even faster than Phoenix (but this should change as soon as we identify the bottleneck)

#### Phalcon Framework (a PHP C extension) ####
PHP 5.6.14-0+deb8u1    
System load: 14-16
```
# ./wrk -t12 -c100 -d60s --timeout 1000 http://pete-phalcon.do/gallery
Running 1m test @ http://pete-phalcon.do/gallery
  12 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    11.25ms   14.32ms 320.80ms   96.75%
    Req/Sec   811.82    222.78     1.39k    67.51%
  580900 requests in 1.00m, 1.01GB read
Requests/sec:   9669.83
Transfer/sec:     17.14MB
```
The performance of the compiled Phalcon framework is really astonishing. It takes
the crown with ease. What happens when Phalcon is compatible with PHP 7? :)    


Now lets up that connections from 100 to 400 and run the test for 3 mins to see who really stands a lot of pressure.   
```
# ./wrk -t12 -c400 -d180s --timeout 1000   
```

#### Phoenix Framework (Elixir) ####
Erlang OTP 18.2.1, Elixir 1.2.0, Phoenix 1.1.0    
System load: 7
```
# ./wrk -t12 -c400 -d180s --timeout 1000 http://pete-phoenix.do:4001/gallery
Running 3m test @ http://pete-phoenix.do:4001/gallery
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   125.44ms   19.75ms 366.21ms   70.69%
    Req/Sec   264.16     52.14   520.00     66.26%
  567906 requests in 3.00m, 1.07GB read
Requests/sec:   3153.33
Transfer/sec:      6.06MB
```
Wow, Phoenix really handles lot of connections really well. It is the only framework to not deliver bad
results or errors, it handles all requests without error. 

The PHP frameworks are disqualified as seen below, unable to get correct benchmarks with all those errors.

#### Slim Framework (PHP) ####
PHP 5.6.14-0+deb8u1 as FPM, Nginx 1.6.2.     
System load: 28,    
ERRORS -> disqualified     
```
# ./wrk -t12 -c400 -d180s --timeout 1000 http://pete-slim.do/gallery
Running 3m test @ http://pete-slim.do/gallery
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    27.77ms   34.68ms 529.63ms   85.57%
    Req/Sec     1.84k   532.79     4.56k    69.47%
  3943598 requests in 3.00m, 1.72GB read
  Non-2xx or 3xx responses: 3578941
Requests/sec:  21897.63
Transfer/sec:      9.77MB
```

PHP 7.0.1        
System load: 18   
ERRORS -> disqualified
```
Sorry forgot to note this one. But stats similar to PHP 5.6 with more correct responses. Still lots of errors and disqualified.
```

#### Phalcon Framework (a PHP C extension) ####
PHP 5.6.14-0+deb8u1    
System load: 18    
ERRORS -> disqualified    
```
# ./wrk -t12 -c400 -d180s --timeout 1000 http://pete-phalcon.do/gallery
Running 3m test @ http://pete-phalcon.do/gallery
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    31.30ms   51.29ms   2.13s    93.17%
    Req/Sec     1.68k   565.24     4.14k    69.94%
  3553864 requests in 3.00m, 2.02GB read
  Non-2xx or 3xx responses: 2895169
Requests/sec:  19733.65
Transfer/sec:     11.51MB
```
