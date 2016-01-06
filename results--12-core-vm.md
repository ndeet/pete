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
System load: 7-8
```
# ./wrk -t12 -c100 -d60s --timeout 1000 http://pete-phoenix.do:4001/gallery
Running 1m test @ http://pete-phoenix.do:4001/gallery
  12 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     2.66ms    2.28ms  99.80ms   93.40%
    Req/Sec     3.22k   421.44     4.98k    69.09%
  2307431 requests in 1.00m, 4.45GB read
Requests/sec:  38399.63
Transfer/sec:     75.81MB
```
Update 2016-01-06:   
After finding the bottleneck we see crazy speed and the expected 10.000 req/s get blown away by 38.000 req/s!

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
This is a really great improvement from PHP 5.6 to PHP 7.

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
The performance of the compiled Phalcon framework is really astonishing compared to slim. What happens when Phalcon is compatible with PHP 7? Maybe it can challenge Phoenix again?  


Now lets up that connections from 100 to 400 and run the test for 3 mins to see who really stands a lot of pressure.   
```
# ./wrk -t12 -c400 -d180s --timeout 1000   
```

#### Phoenix Framework (Elixir) ####
Erlang OTP 18.2.1, Elixir 1.2.0, Phoenix 1.1.0    
System load: 7
```
2016-01-06: not yet updated with new test results
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

Ok, now lets try to get Phoenix throw errors. We throw whopping 48 treads each 500 connections at it. What happened? Not a single error returned. Amazing. It is more likely that the 1Gb/s uplink was filled than Phoenix was maxed out :)
```
# ./wrk -t48 -c500 -d60s --timeout 1000 http://pete-phoenix.do:4001/gallery
Running 1m test @ http://pete-phoenix.do:4001/gallery
  48 threads and 500 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    43.55ms  111.75ms   3.36s    91.04%
    Req/Sec     0.86k   224.25     2.68k    69.38%
  2473840 requests in 1.00m, 4.77GB read
Requests/sec:  41162.79
Transfer/sec:     81.27MB
```

Thats just crazy, no errors >41000 req/s and look at that latency times! Ok, max request is now 3s but hey NO SINGLE ERROR thrown!
