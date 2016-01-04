### Detailed results: VM 2 cores, 2gb RAM ###

Hardware: [Digitalocean VM 2-cores, 2gb RAM](https://www.digitalocean.com/pricing)    
Network: 1 Gb/s on digitalocean, 30 mbit on my side    
OS: Debian Jessie 8.2 
Phoenix stack: Erlang 18.2.1 (SMP + hipe enabled), Elixir 1.2.0, Phoenix 1.1.0   
PHP Stack: PHP 5.6.14-0-deb8u1, PHP 7.0.1 (self compiled), as PHP-FPM, OPcache enabled, Nginx 1.6.2    
(configs same as ```configs/raspberry-pi2``` directory)

#### Phoenix Framework (Elixir) ####
Erlang OTP 18.2.1, Elixir 1.2.0, Phoenix 1.1.0   
```
$ wrk -t4 -c100 -d60s --timeout 2000 http://pete-phoenix.do:4001/gallery
Running 1m test @ http://pete-phoenix.do:4001/gallery
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    83.64ms   35.18ms 518.42ms   89.08%
    Req/Sec   299.34     82.11   490.00     73.67%
  70758 requests in 1.00m, 134.10MB read
Requests/sec:   1178.11
Transfer/sec:      2.23MB
```

#### Slim Framework (PHP) ####
PHP 5.6.14-0+deb8u1 as FPM, Nginx 1.6.2
```
$ wrk -t4 -c100 -d60s --timeout 2000 http://pete-slim.do/gallery
Running 1m test @ http://pete-slim.do/gallery
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   138.08ms   15.72ms 641.95ms   76.50%
    Req/Sec   181.30     27.03   250.00     67.28%
  43250 requests in 1.00m, 75.89MB read
Requests/sec:    719.81
Transfer/sec:      1.26MB
```

PHP 7.0.1 (self compiled)
```
$  wrk -t4 -c100 -d60s --timeout 2000 http://pete-slim.do/gallery
Running 1m test @ http://pete-slim.do/gallery
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    85.52ms   12.60ms 217.38ms   72.83%
    Req/Sec   292.28     39.74   424.00     68.68%
  69710 requests in 1.00m, 123.98MB read
Requests/sec:   1160.71
Transfer/sec:      2.06MB
```
Ok, seems to confirm my guess from [Raspberry Pi results](results--raspberry-pi2.md) that something is 
broken with the PHP 7.0.1 build on ARM. Now, as expected, PHP 7 outperforms PHP 5.6.

#### Phalcon Framework (a PHP C extension) ####
PHP 5.6.14-0+deb8u1
```
$  wrk -t4 -c100 -d60s --timeout 2000 http://pete-phalcon.do/gallery
Running 1m test @ http://pete-phalcon.do/gallery
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    68.22ms   16.49ms 366.38ms   76.87%
    Req/Sec   365.36     68.21   515.00     69.39%
  87284 requests in 1.00m, 154.74MB read
Requests/sec:   1452.98
Transfer/sec:      2.58MB
```
The performance of the compiled Phalcon framework is really good and takes suprisingly the 
crown.
