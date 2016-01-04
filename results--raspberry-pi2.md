### Detailed results: Raspberry Pi 2 ###
Hardware: Raspberry Pi 2 (4 cores, 1 GB Ram) [Hardware specs](https://www.raspberrypi.org/products/raspberry-pi-2-model-b/)    
Network: connection through 100 Mbit RasPi <-> Router <-> USB dongle Macbook Pro    
OS: Debian Jessie 8 (4.1.13-v7+) ARM   
Phoenix stack: Erlang 18.2.1, Elixir 1.2.0, Phoenix 1.1.0   
PHP Stack: PHP 5.6.14-0-deb8u1, PHP 7.0.1 (self compiled), as PHP-FPM, OPcache enabled, Nginx 1.6.2    
(see also ```configs/raspberry-pi2``` directory)

#### Phoenix Framework (Elixir) ####
Erlang OTP 18.2.1, Elixir 1.2.0, Phoenix 1.1.0   
```
$ wrk -t4 -c100 -d60s --timeout 2000 http://pete-phoenix.pi:4001/gallery
Running 1m test @ http://pete-phoenix.pi:4001/gallery
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   173.46ms   12.52ms 261.63ms   71.21%
    Req/Sec   144.51     28.08   230.00     70.79%
  34569 requests in 1.00m, 65.08MB read
Requests/sec:    575.23
Transfer/sec:      1.08MB
```
Looks like a really good result right? Let's see how a not compiled framework like Slim Framework handles the task.

#### Slim Framework (PHP) ####
PHP 5.6.14-0+deb8u1 as FPM, Nginx 1.6.2
```
$ wrk -t4 -c100 -d60s --timeout 2000 http://pete-slim.pi/gallery
Running 1m test @ http://pete-slim.pi/gallery
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   844.07ms  101.49ms   1.25s    57.28%
    Req/Sec    31.25     18.32   118.00     66.15%
  7072 requests in 1.00m, 12.30MB read
Requests/sec:    117.72
Transfer/sec:    209.70KB
```
Yep, pretty poor, nearly 5 times slower than Elixir. Ok, PHP 7 should be twice as 
fast, so I compiled it on the Raspberry Pi but the results where even poorer. Seems
there is some problem with ARM build? Because on the amd64 VM the throughput is 
better, see other results: [results--2-core-vm.md](results--2-core-vm.md) [results--12-core-vm.md](results--12-core-vm.md)

PHP 7.0.1
```
$ wrk -t4 -c100 -d60s --timeout 2000 http://pete-slim.pi/gallery
Running 1m test @ http://pete-slim.pi/gallery
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.50s   553.34ms   4.22s    93.33%
    Req/Sec     9.26      6.17    40.00     67.55%
  1665 requests in 1.00m, 2.94MB read
Requests/sec:     27.71
Transfer/sec:     50.04KB
```
Holy s..., that's really a bad performance for PHP 7. I expected 1.5 to 2x improvement 
towards PHP 5.6. I also wanted to try HHVM to compare but it seems not compile on ARM (Raspberry Pi).

Ok, not expecting much from Phalcon but what followed was really a big suprise, see below.

#### Phalcon Framework (a PHP C extension) ####
PHP 5.6.14-0+deb8u1
```
$ wrk -t4 -c100 -d60s --timeout 2000 http://pete-phalcon.pi/gallery
Running 1m test @ http://pete-phalcon.pi/gallery
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   191.42ms   17.77ms 415.41ms   82.85%
    Req/Sec   130.87     28.42   220.00     62.89%
  31322 requests in 1.00m, 55.14MB read
Requests/sec:    521.19
Transfer/sec:      0.92MB
```
This is really amazing, never thought that any PHP framework (as they are not compiled)
will come near Phoenix, but Phalcon is even faster as it is partly compiled.    

No tests for PHP 7 as Phalcon currently does not support it yet.   
