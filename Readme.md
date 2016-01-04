# Pete Projects #

To give the child a name, Pete simply stands for PErformance TEst. 

## Why ##
Learning new languages like Elixir alone is already exciting but make it a bit more exciting by trying new frameworks and compare their speed against each other.
Because I'm a PHP (mostly Drupal) guy and just discovered Elixir I want to take it as opportunity to learn functional programming paradigms but also see how Elixir's (Erlang) concurrency model speeds out our traditional languages such as PHP. Therefore I took the Elixir web framework Phoenix Framework and try to compare it in a similar structure and setup to Slim Framework (PHP) and Phalcon (PHP as C extension) and see how the performance differs.

## What ##
I choose to do a very simplistic gallery app, with no model and database backend. 
Only router, controller, view and templates are used.

### Requriements ###
Image gallery:       
- Headline    
- 4 images (filenames as array/list with copyright info)    
- 3 Templates/partials (base, gallery, image)    
- CSS    
- No model and database backend (only controller / view / templates)    

### Framworks ###
- [Phoenix Framework (Elixir)](http://www.phoenixframework.org/)    
- [SlimPHP (PHP)](http://www.slimframework.com/)    
- [Phalcon (PHP, as compiled C extension)](https://phalconphp.com/en)    


## How ##
I'm not familar with any of the frameworks I have chosen here, so bare with me if some structure is a complete mess :)

See subdirectories for framework specific information.

## Test Results ##
I made multiple test runs on Raspberry Pi 2 (4 cores) and some Digitalocean VMs 
with 2 and 12 cores to check how the frameworks deal with multiple cores and concurrency.

### Testing using wrk ###
Using [wrk](https://github.com/wg/wrk) as benchmarking tool with this or similar command:    
```
$ wrk -t4 -c100 -d60s --timeout 2000 http://ip-or-host.tld/gallery
```

### Language versions used for frameworks ###
PHP 5: PHP 5.6.14-0-deb8u1 as PHP-FPM, OPcache enabled, Nginx 1.6.2    
PHP 7: PHP 7.0.1 (self compiled) as PHP-FPM, OPcache enabled, Nginx 1.6.2    
Phoenix: Erlang 18.2.1 (SMP + hipe enabled), Elixir 1.2.0, Phoenix 1.1.0       

### Testing summary: Raspberry Pi 2 (Model B) ###
One nice thing about the Raspberry Pi is that the hardware is cheap and easy to 
get and test results can (hopefully) be reproduced and compared easier.           

| Framework      | Throughput (req/s) | Latency avg (ms) |     Stdev (ms) |
| :------------- | -----------------: | ---------------: | -------------: |
| Phoenix        |            575.23  |          173.46  |         12.52  |
| Phalcon        |            521.19  |          191.40  |         17.77  |
| Slim (PHP 5.6) |            117.72  |          844.07  |        101.49  |
| Slim (PHP 7.0) |             27.71  |        >3500.00  |        553.34  |

Detailed results and specs: [results--raspberry-pi2.md](results--raspberry-pi2.md)

### Testing summary: Virtual Machine with 2 cores ###
Basic digitalocean VM with SSD and 2 cores, 2gb ram          

Pretty interesting that with fewer cores Phoenix is close but does not take the 
crown this time. 

| Framework      | Throughput (req/s) | Latency avg (ms) |     Stdev (ms) |
| :------------- | -----------------: | ---------------: | -------------: |
| Phalcon        |           1452.98  |           68.22  |         16.49  |
| Phoenix        |           1178.11  |           83.64  |         35.18  |
| Slim (PHP 7.0) |           1160.71  |           85.52  |         12.60  |
| Slim (PHP 5.6) |            719.81  |          138.08  |         15.72  |

Detailed results and specs: [results--2-core-vm.md](results--2-core-vm.md)

But now time to get really into multi core business and see who can handle concurrency best:

### Testing summary: Virtual Machine with 12 cores ###
App VM: Digitalocean VM with SSD and 12 cores, 32gb RAM     
Benchmark VM: Digitalocean VM with SSD and 4 cores, 8 gb RAM
Connected over 1 Gb/s

We do the same number of connections but with more threads first, then let's try
something insane and quadruple the number of connections and see what happens.

```
# ./wrk -t12 -c100 -d60s --timeout 1000   
```
| Framework      | Throughput (req/s) | Latency avg (ms) |     Stdev (ms) |
| :------------- | -----------------: | ---------------: | -------------: |
| Phalcon        |           8269.46  |           12.54  |          9.71  |
| Slim (PHP 7.0) |           4937.27  |           19.75  |          8.71  |
| Phoenix *      |           3065.37  |           31.29  |          7.04  |
| Slim (PHP 5.6) |           2619.17  |           36.95  |         11.61  |

\* I don't know why yet but Phoenix (Erlang VM) somehow seem to not use the full potential 
and resources of the VM. Even Slim (not compiled in any way) can catch up near Phoenix... see detailed results for more comments.
   
   
Ok, get a bit extreme and throw 12 threads with 400 connections onto the app server:   
```
# ./wrk -t12 -c400 -d180s --timeout 1000   
```
| Framework      | Throughput (req/s) | Latency avg (ms) |     Stdev (ms) |
| :------------- | -----------------: | ---------------: | -------------: |
| Phoenix        |           3153.33  |          125.44  |         19.75  |
| Phalcon        |                 -  |               -  |             -  |
| Slim (PHP 7.0) |                 -  |               -  |             -  |
| Slim (PHP 5.6) |                 -  |               -  |             -  |

Even though Phoenix still not using all system ressources (system load 7-8) it is the
only framework which handles all requests without error. The PHP frameworks even unable
to handle 200 connections without erros and bad requests. So this is really a big point for
Phoenix as the site is even with 400 connections always available and fast.

Detailed results, specs and comments: [results--12-core-vm.md](results--12-core-vm.md)


## Configuration ##
Some configs for PHP and Nginx can be found in ```configs``` directory:    

**Raspberry PI + 2 core VM configs for Nginx + PHP-FPM pool:**    
[configs/raspberry-pi2/nginx.conf](configs/raspberry-pi2/nginx.conf)      
[configs/raspberry-pi2/php-fpm_pool.d_www.conf](configs/raspberry-pi2/php-fpm_pool.d_www.conf)     

**12 Core VM**    
[configs/big-machine/nginx.conf](configs/big-machine/nginx.conf)      
[configs/big-machine/php-fpm_pool.d_www.conf](configs/big-machine/php-fpm_pool.d_www.conf)    

**Common configs (Nginx vhosts used an all testsystems):**     
[configs/common/phalcon_nginx_vhost](configs/common/phalcon_nginx_vhost)        
[configs/common/slim_nginx_vhost](configs/common/slim_nginx_vhost)   
[configs/common/php.ini](configs/common/php.ini) (default PHP 5.6.14 php fpm ini shipping w Debian 8.2)   
[configs/common/phpinfo.html](configs/common/phpinfo.html)   

## Credits / inspiration  
I was inspired by these great guys but wanted to do it my way and see the results with a slightly more complex testapp.    
http://blog.onfido.com/using-cpus-elixir-on-raspberry-pi2/    
(title is a bit misleading because also PHP with FPM uses all CPUs pretty much, but more to that in a blog post)   
 
Comparison from Chris McCord (creator of Phoenix) with Rails:     
http://www.littlelines.com/blog/2014/07/08/elixir-vs-ruby-showdown-phoenix-vs-rails/    

Followup to above mentioned comparison but extended to Go, Ruby, NodeJS frameworks:   
https://github.com/mroth/phoenix-showdown      
