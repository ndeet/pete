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
$ wrk -t4 -c100 -d60s --timeout 2000 http://pete-slim.do/gallery
Running 1m test @ http://pete-slim.do/gallery
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   143.40ms   20.78ms 472.62ms   79.73%
    Req/Sec   174.25     30.13   242.00     68.78%
  41635 requests in 1.00m, 73.06MB read
Requests/sec:    693.11
Transfer/sec:      1.22MB
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
$ wrk -t4 -c100 -d60s --timeout 2000 http://pete-slim.do/gallery
Running 1m test @ http://pete-slim.do/gallery
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    71.26ms   13.56ms 584.27ms   85.27%
    Req/Sec   350.67     49.37   474.00     72.49%
  83786 requests in 1.00m, 149.02MB read
Requests/sec:   1394.63
Transfer/sec:      2.48MB
```
Ok, seems to confirm my guess from [Raspberry Pi results](results--raspberry-pi2.md) that something is 
broken with the PHP 7.0.1 build on ARM. Now, as expected, PHP 7 outperforms PHP 5.6.

#### Phalcon Framework (a PHP C extension) ####
PHP 5.6.14-0+deb8u1
```
$ wrk -t4 -c100 -d60s --timeout 2000 http://pete-phalcon.do/gallery
Running 1m test @ http://pete-phalcon.do/gallery
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    58.28ms   16.74ms 710.12ms   95.80%
    Req/Sec   431.88     49.61   580.00     70.10%
  103126 requests in 1.00m, 182.83MB read
Requests/sec:   1716.16
Transfer/sec:      3.04MB
```
The performance of the compiled Phalcon framework is really good and takes suprisingly the 
crown.
