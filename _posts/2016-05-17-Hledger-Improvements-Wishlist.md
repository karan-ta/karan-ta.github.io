---
layout: post
title: Hledger Improvements Wishlist.
date: 2016-05-17
author: Karan Ahuja
published: true
---
In this post, I note down improvements in hledger I would love to use myself.

When I started using hledger around a month back, 
I tweeted this:
<br/>
<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">many happy moments today at work while trying out hledger - <a href="https://t.co/LP4dUbwQSq">https://t.co/LP4dUbwQSq</a><br>Thank you <a href="https://twitter.com/hashtag/hledger?src=hash">#hledger</a></p>&mdash; karan ahuja (@karan_ta) <a href="https://twitter.com/karan_ta/status/719511436729266176">April 11, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<br/>
Luckily Simon Michael, The creator of hledger
tweeted back :)  :

<blockquote class="twitter-tweet" data-conversation="none" data-lang="en"><p lang="en" dir="ltr"><a href="https://twitter.com/karan_ta">@karan_ta</a> Great! How could we improve it ?<a href="https://twitter.com/hashtag/hledger?src=hash">#hledger</a></p>&mdash; Simon Michael (@simonkwmichael) <a href="https://twitter.com/simonkwmichael/status/719533992303693824">April 11, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>



<br/><br/>
Recently, I completed making journal files for my entire family using
hledger.
The process was quite smooth.
A few improvements that could have saved some time
are below:

### The Hledger add command does not have undo feature or back feature.
If you make a mistake in any step of hledger add,
you cannot undo or go back to the previous step.
you just have to ctrl-c and restart that particular transaction.


### We should be able to generate balance sheet, P&L sheet.
During audit, we need balance sheet, P&L sheet, 
schedule of assets pdf files.
It should be possible to generate these through hledger.
I shall study the format of the documents required to be 
generated during audit and elaborate further on this.


### Add checks for duplicate transaction.
There should be checks for duplicate transaction if one adds the same transaction 
on the same date.
While adding many transactions from large csv - we could be making this 
mistake.
so there can be a check for this in the hledger add command.

### Better auto completion during hledger add command.
I need to elaborate on this but distinctly remember getting incorrect auto complete
suggestions at some points with hledger add.
With hledger add - I should get better auto completion.
Fuzzy logic can be used to allow us to pick auto completion suggestions.
Also the web ui may be more suitable for auto complete suggestions as 
compared to command line.

### Sync with heads used by accountant.
When I showed my ledger to my Chartered accountant,
he was habitually using different heads for checking accounts,
depreciation of assets.
There should be a way to sync my hledger account heads 
to those of tally used by my CA.
There should be a way to substitute account heads while
looking at a report in hledger.
I shall ask my accountant for a list of the account heads
that he uses and add them here for refrence.

### Compute Professional tax , service tax , tds from hledger data.
There could be commands to compute Professional tax, service tax, TDS
from hledger data.
One could maybe even pay the taxes and file returns from within hledger
itself.



This list can serve as a todo for me and other 
aspiring contributors to work on.

Happy DIY Accounting  :) 
