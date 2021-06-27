---
author: "Dennis Lee"
title: "Building a Telegram Chat with a MT4 Forex Trading Expert Advisor"
date: "Sat, 05 Oct 2019 16:00:00 +0800"
description: "Telegram isn't just for sending and receiving chat messages. It's also for automating your dialog flow, including work flow. Using a Telegram Bot gives you the ability to check prices, query status, manage trades, and even have a fun conversation. And if you're a serious crypto or forex trader, you can create your own Telegram Bot to manage your order flow."
draft: false
hideToc: false
enableToc: true
enableTocContent: true
authorEmoji: 👨
tags:
- telegram
- mt4
- bot
---

## Introduction

[Telegram](https://telegram.org/) isn't just for sending and receiving chat messages. It's also for automating your dialog flow, including work flow. Using a Telegram Bot gives you the ability to check prices, query status, manage trades, and even have a fun conversation. And if you're a serious crypto or forex trader, you can create your own Telegram Bot to manage your order flow.

In this tutorial you'll use a Telegram Bot to query your orders on a Metatrader 4 account. You'll create a Telegram Bot ["bot"], build an Expert Advisor ["EA"] that can listen and process messages from a user, as well as reply to the user with orders and account data.

## Prerequisites

* Metatrader 4 ["MT4"] client and demo account with any broker.
* Telegram Bot created in your Telegram account. The tutorial [How to Create a New Telegram Bot](https://github.com/dennislwm/MT4-Telegram-Bot-Recon) walks you through creating a bot and configuring your MT4 client.
* [Postman](https://www.getpostman.com/) Windows application to understand how the Telegram HTTP API works.

## Step 1 - Peeking into Telegram's HTTP API with Postman

Before diving into the MT4 EA build, let's take a peek at how the Telegram HTTP API work, in particular the **getUpdates** method, with the Postman app.

The **getUpdates** method returns messages from all channels, groups, and chats that the Bot is a member of.

In other words, the JSON message returned by this function can get crowded very quickly, if the Bot is a member of more than one group or channel. 

Each Bot can also have a private chat with whomever sends a private message to the Bot.

For example, my Bot belongs to both a channel **TradeTitanSignal** and a private chat where I can sent it private messages.

```
     GET https://api.telegram.org/bot**token**/getUpdates
```

```json
     {
         "ok": true,
         "result": [
             {
                 "update_id": 769794061,
                 "channel_post": {
                     "message_id": 4,
                     "chat": {
                         "id": -1001326947729,
                         "title": "TradeTitanSignal",
                         "username": "tradetitansignal",
                         "type": "channel"
                     },
                     "date": 1569929874,
                     "text": "hi i’m dennis"
                 }
             },
             {
                 "update_id": 769794062,
                 "message": {
                     "message_id": 4,
                     "from": {
                         "id": 902090608,
                         "is_bot": false,
                         "first_name": "Dennis",
                         "last_name": "Lee",
                         "language_code": "en"
                     },
                     "chat": {
                         "id": 902090608,
                         "first_name": "Dennis",
                         "last_name": "Lee",
                         "type": "private"
                     },
                     "date": 1569931564,
                     "text": "hi"
                 }
             }
         ]
     }
```

The above response in JSON format requires some explanation:

* The **update_id** value represents a sequential number that is assigned to every message regardless of whether the message is from a channel post, or a private message, etc.

```json
                 "update_id": 769794061,

                 "update_id": 769794062,
```

* The update id is followed by the message type, i.e **channel_post** for a channel message, while a private message begins with **message** head.
* A channel has a negative **chat_id**, so we may have to use **chat_title** to scan for a channel.

```json
                     "chat": {
                         "id": -1001326947729,
                         "title": "TradeTitanSignal",
```

* A private chat has a positive **chat_id**, so we can use **sendMessage** method to chat to the person.

```json
                     "chat": {
                         "id": 902090608,
                         "first_name": "Dennis",
```

* A channel post has **chat_title** and **chat_username**, but a private message has **from_is_bot**, **from_first_name**, **from_last_name**, **chat_first_name**, and **chat_last_name**.

```json
                 "update_id": 769794061,
                 "channel_post": {
                     "message_id": 4,
                     "chat": {
                         "id": -1001326947729,
                         "title": "TradeTitanSignal",
                         "username": "tradetitansignal",
                         "type": "channel"
                     },
                     "date": 1569929874,
                     "text": "hi i’m dennis"
```

* Both channel post and private message have **update_id**, **message_id**, **chat_id**, **chat_type**, **date** and **text**. For both channel post and private message, the content can be accessed using **text**. 

```json
                 "update_id": 769794062,
                 "message": {
                     "message_id": 4,
                     "from": {
                         "id": 902090608,
                         "is_bot": false,
                         "first_name": "Dennis",
                         "last_name": "Lee",
                         "language_code": "en"
                     },
                     "chat": {
                         "id": 902090608,
                         "first_name": "Dennis",
                         "last_name": "Lee",
                         "type": "private"
                     },
                     "date": 1569931564,
                     "text": "hi"
```

* The response has a limit of 100 messages, but it doesn't clear automatically each time you call the **getUpdate** method, unless you pass it an **offset** parameter.
* After processing the above messages, you should call the **getUpdates** method, but with an offset value equal to the highest **update_id** + 1, in this example above, i.e. 769794062 + 1.

```
     GET https://api.telegram.org/bot**token**/getUpdates?offset=769794063
```

We should get an empty response if there are no new messages.

It is important to note that calling the **getUpdates** method again, without the offset value, returns an empty response. 

This is because the Telegram API server stores the last offset that we passed as a parameter, so that we don't have to specify the same offset again.

```json
     {
         "ok": true,
         "result": []
     }
```

## Step 2 - Creating a New MT4 Expert Advisor

In this section, let's create a new Expert Advisor ["EA"] in MetaEditor, and name the EA **TelegramRecon.mq4**.

Type the following code into the above MQ4 file:

```c++
     #property copyright "Copyright 2019, Dennis Lee"
     #property link      "https://github.com/dennislwm/MT4-Telegram-Bot-Recon"
     #property version   "000.900"
     #property strict
     //---- Assert Basic externs
     #include <plusinit.mqh>
     #include <plusbig.mqh>
     #include <Telegram.mqh>
     //|-----------------------------------------------------------------------------------------|
     //|                           E X T E R N A L   V A R I A B L E S                           |
     //|-----------------------------------------------------------------------------------------|
     extern string s1="-->TGR Settings<--";
     extern string s1_1="Token - Telegram API Token";
     input string  TgrToken;
     //|-----------------------------------------------------------------------------------------|
     //|                           I N T E R N A L   V A R I A B L E S                           |
     //|-----------------------------------------------------------------------------------------|
     CCustomBot bot;
     int intResult;
     //|-----------------------------------------------------------------------------------------|
     //|                             I N I T I A L I Z A T I O N                                 |
     //|-----------------------------------------------------------------------------------------|
     int OnInit()
     {
        InitInit();
        BigInit();
        
        bot.Token(TgrToken);
        intResult=bot.GetMe();
       
     //--- create timer
        EventSetTimer(3);
        OnTimer();
        
     //---
        return(INIT_SUCCEEDED);
     }
     //|-----------------------------------------------------------------------------------------|
     //|                             D E I N I T I A L I Z A T I O N                             |
     //|-----------------------------------------------------------------------------------------|
     void OnDeinit(const int reason)
     {
     //--- destroy timer
        EventKillTimer();
        
        BigDeInit();
     }
     //+------------------------------------------------------------------+
     //| Expert tick function                                             |
     //+------------------------------------------------------------------+
     void OnTick()
       {
     //---
        
       }
     void OnTimer()
     {
     //--- Assert intResult=0 (success)
        if( intResult!=0 ) {
           BigComment( "Error: "+GetErrorDescription(intResult) );
           return;
        }
        
        BigComment( "Bot name: "+bot.Name() );
     }
```

First, we include the file **Telegram.mqh**, which provides the class CCustomBot to manage a Telegram Bot.

```c++
     #include <Telegram.mqh>
```

Second, we declare an input variable **TgrToken**, which the user must provide. This is the HTTP API token for the Telegram Bot.

```c++
     input string  TgrToken;
```

Third, we declare two global variables:

(1) The variable **bot** is of type **CCustomBot**, which is a class defined in **Telegram.mqh**. This bot is used to send and process Telegram messages.

(2) The variable **intResult** is an integer, which holds the result of the **bot.GetMe()** method. The method returns zero if successful.

```c++
     CCustomBot bot;
     int intResult;
```

Fourth, in the **OnInit()** function, we call the **bot.Token()** method and passing it the variable **TgrToken**.

Then we call the **bot.GetMe()** method, which returns a zero if successful. 

We then set the Timer to repeat every three seconds to call the **OnTimer()** function.

```c++
        bot.Token(TgrToken);
        intResult=bot.GetMe();
       
     //--- create timer
        EventSetTimer(3);
        OnTimer();
```

Finally, in the **OnTimer()** function, we check the variable **intResult**. If it is a non-zero value, then we display the Error Description on the chart.

Otherwise, if the value of **intResult** is zero (success), then we display the bot Name using the **bot.Name()** method.

```c++
        if( intResult!=0 ) {
           BigComment( "Error: "+GetErrorDescription(intResult) );
           return;
        }
        
        BigComment( "Bot name: "+bot.Name() );
```

Compile the above source code, and you should see the **TelegramRecon** EA in the Navigator under the Expert Advisors tab.

![][4]

[4]: https://dennislwm.netlify.app/images/building-a-telegram-chat-with-a-mt4-forex-trading-expert-advisor/step-5---implementing-the-bot-commands.png

## Step 3 - Running the MT4 EA for First Time

Before running the EA, we have to add a URL to the List of allowed WebRequest URLs in MT4.

Click on menu **Tools --> Options (Ctrl+O)**, then click on menu tab **Expert Advisors**.

Check the box Allow WebRequest for listed URL, and add the URL **https://api.telegram.org**

Click OK button to save the dialog window.

Next, attach the EA to any chart, and in the Input dialog window, enter your unique HTTP API token in the Input field **TgrToken**.

If you had done every step above correctly, you should see your Bot Name displayed on the chart.

![][2]

[2]: https://dennislwm.netlify.app/images/building-a-telegram-chat-with-a-mt4-forex-trading-expert-advisor/step-3---running-the-mt4-ea-for-first-time.png

## Step 4 - Building a Bot Query Tool

In order to build a Bot Query Tool, we have to be able to both send and process messages to and from a user respectively.

In this section, let's create a new include file in MetaEditor, and name the file **CPlusBotRecon.mqh**.

Type the following code into the above MQH file:

```c++
     #property copyright "Copyright 2019, Dennis Lee"
     #property link      "https://github.com/dennislwm/MT4-Telegram-Bot-Recon"
     #property strict
     //---- Assert Basic externs
     #include <PlusBotRecon.mqh>
     #include <Telegram.mqh>
     //|-----------------------------------------------------------------------------------------|
     //|                               M A I N   P R O C E D U R E                               |
     //|-----------------------------------------------------------------------------------------|
     class CPlusBotRecon: public CCustomBot
     {
     public:
        void ProcessMessages(void)
        {
           string msg=NL;
           const string strOrderTicket="/orderticket";
           const string strHistoryTicket="/historyticket";
           int ticket=0;
           for( int i=0; i<m_chats.Total(); i++ ) {
              CCustomChat *chat=m_chats.GetNodeAtIndex(i);
              
              if( !chat.m_new_one.done ) {
                 chat.m_new_one.done=true;
                 
                 string text=chat.m_new_one.message_text;
                 
                 if( text=="/ordertotal" ) {
                    SendMessage( chat.m_id, BotOrdersTotal() );
                 }
                 
                 if( text=="/ordertrade" ) {
                    SendMessage( chat.m_id, BotOrdersTrade() );
                 }
                 if( StringFind( text, strOrderTicket )>=0 ) {
                    ticket = StringToInteger( StringSubstr( text, StringLen(strOrderTicket)+1 ) );
                    if( ticket>0 ) 
                       SendMessage( chat.m_id, BotOrdersTicket(ticket) );
                    else {
                       msg = StringConcatenate(msg,"Correct format is: /orderticket **ticket**");
                       SendMessage( chat.m_id, msg );
                    }
                 }
                 if( text=="/historytotal" ) {
                    SendMessage( chat.m_id, BotOrdersHistoryTotal() );
                 }
                 if( StringFind( text, strHistoryTicket )>=0 ) {
                    ticket = StringToInteger( StringSubstr( text, StringLen(strHistoryTicket)+1 ) );
                    if( ticket>0 ) 
                       SendMessage( chat.m_id, BotHistoryTicket(ticket) );
                    else {
                       msg = StringConcatenate(msg,"Correct format is: /historyticket **ticket**");
                       SendMessage( chat.m_id, msg );
                    }
                 }
                 
                 if( text=="/account" ) {
                    SendMessage( chat.m_id, BotAccount() );
                 }
                 
                 msg = StringConcatenate(msg,"My commands list:",NL);
                 msg = StringConcatenate(msg,"/ordertotal-return count of orders",NL);
                 msg = StringConcatenate(msg,"/ordertrade-return ALL opened orders",NL);
                 msg = StringConcatenate(msg,"/orderticket **ticket**-return an order or a chain of history by ticket",NL);
                 msg = StringConcatenate(msg,"/historytotal-return count of history",NL);
                 msg = StringConcatenate(msg,"/historyticket **ticket**-return a history or chain of history by ticket",NL);
                 msg = StringConcatenate(msg,"/account-return account info",NL);
                 msg = StringConcatenate(msg,"/help-get help");
                 if( text=="/help" ) {
                    SendMessage( chat.m_id, msg );
                 }
              }
           }
        }
     };
```

First, we include both the files **PlusBotRecon.mqh** and **Telegram.mqh**. The first MQH file is one that we will create later that does all the order queries, while the latter MQH contains the class CCustomBot, as previously discussed.

```c++
     #include <PlusBotRecon.mqh>
     #include <Telegram.mqh>
```

Second, we declare a new class **CPlusBotRecon**, which inherits all the methods and data of **CCustomBot.** In addition, we declare a new public method **ProcessMessage()**.

```c++
     class CPlusBotRecon: public CCustomBot
```

The method **ProcessMessage()** checks and parses any messages into commands, prepended by a slash ["/"], that we defined as follows:

1. /ordertotal - Return a count of opened orders
1. /ordertrade - Return ALL opened orders, where EACH order includes ticket, symbol, type, lots, openprice, stoploss, takeprofit, and prevticket
1. /orderticket **ticket** - Return an order by ticket
1. /historytotal - Return a count of history
1. /historyticket **ticket** - Return a history by ticket
1. /account - Return account number, currency, balance, equity, margin, freemargin, and profit.
1. /help - Display a list of bot commands

Finally, let's create a new include file in MetaEditor, and name the file **PlusBotRecon.mqh**.

Type the following code into the above MQH file:

```c++
     #property copyright "Copyright 2019, Dennis Lee"
     #property link      "https://github.com/dennislwm/MT5-MT4-Telegram-API-Bot"
     #property strict
     #define  NL "\n"
     //|-----------------------------------------------------------------------------------------|
     //|                                O R D E R S   S T A T U S                                |
     //|-----------------------------------------------------------------------------------------|
     string BotOrdersTotal(bool noPending=true)
     {
        return( "" );
     }
     string BotOrdersTrade(int pos=0, bool noPending=true)
     {
        return( "" );
     }
     string BotOrdersTicket(int ticket, bool noPending=true)
     {
        return( "" );
     }
     string BotHistoryTicket(int ticket, bool noPending=true)
     {
        return( "" );
     }
     string BotOrdersHistoryTotal(bool noPending=true)
     {
        return( "" );
     }
     //|-----------------------------------------------------------------------------------------|
     //|                               A C C O U N T   S T A T U S                               |
     //|-----------------------------------------------------------------------------------------|
     string BotAccount(void)
     {
        return( "" );
     }
     //|-----------------------------------------------------------------------------------------|
     //|                           I N T E R N A L   F U N C T I O N S                           |
     //|-----------------------------------------------------------------------------------------|
     string strBotInt(string key, int val)
     {
        return( StringConcatenate(NL,key,"=",val) );
     }
     string strBotDbl(string key, double val, int dgt=5)
     {
        return( StringConcatenate(NL,key,"=",NormalizeDouble(val,dgt)) );
     }
     string strBotTme(string key, datetime val)
     {
        return( StringConcatenate(NL,key,"=",TimeToString(val)) );
     }
     string strBotStr(string key, string val)
     {
        return( StringConcatenate(NL,key,"=",val) );
     }
     string strBotBln(string key, bool val)
     {
        string valType;
        if( val )   valType="true";
        else        valType="false";
        return( StringConcatenate(NL,key,"=",valType) );
     }
     //|-----------------------------------------------------------------------------------------|
     //|                            E N D   O F   I N D I C A T O R                              |
     //|-----------------------------------------------------------------------------------------|
```

For now, we simply return an empty string in each of our above function.

Let's modify our previous EA **TelegramRecon.mq4** in MetaEditor.

Find the following code into the above MQ4 file and add the include file **CPlusBotRecon.mqh** below as follows:

```c++
     #include <Telegram.mqh>
     #include <CPlusBotRecon.mqh>
```

Next, find and replace the following code:

```c++
     CCustomBot bot;
```

with our inherited class:

```c++
     CPlusBotRecon bot;
```

Next, find the **BigComment** code in the OnTimer() function and add two more lines below it as follows

```c++
     BigComment( "Bot name: "+bot.Name() );      
     bot.GetUpdates();      
     bot.ProcessMessages();
```

Compile and attach the EA to any chart, and in the Input dialog window, enter your unique HTTP API token in the Input field **TgrToken**.

Open your Telegram app and send a message "/help" to your Telegram Bot. You should get the following response:

{{< img src="/images/building-a-telegram-chat-with-a-mt4-forex-trading-expert-advisor/step-4---building-a-bot-query-tool.png" title="" alt="building-a-bot-query-tool" position="center" >}}

## Step 5 - Implementing the Bot Commands

The final step is to actually implement the empty functions in our include file **PlusBotRecon.mqh**.

Type the following code into the above MQ4 file:

```c++
     //|-----------------------------------------------------------------------------------------|
     //|                                O R D E R S   S T A T U S                                |
     //|-----------------------------------------------------------------------------------------|
     string BotOrdersTotal(bool noPending=true)
     {
        int count=0;
        int total=OrdersTotal();
     //--- Assert optimize function by checking total > 0
        if( total<=0 ) return( strBotInt("Total", count) );   
     //--- Assert optimize function by checking noPending = false
        if( noPending==false ) return( strBotInt("Total", total) );
        
     //--- Assert determine count of all trades that are opened
        for(int i=0;i<total;i++) {
           OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
        //--- Assert OrderType is either BUY or SELL
           if( OrderType() <= 1 ) count++;
        }
        return( strBotInt( "Total", count ) );
     }
     string BotOrdersTrade(int pos=0, bool noPending=true)
     {
        int count=0;
        string msg="";
        const string strPartial="from #";
        int total=OrdersTotal();
     //--- Assert optimize function by checking total > 0
        if( total<=0 ) return( msg );   
     //--- Assert determine count of all trades that are opened
        for(int i=0;i<total;i++) {
           OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
        //--- Assert OrderType is either BUY or SELL if noPending=true
           if( noPending==true && OrderType() > 1 ) continue ;
           else count++;
        //--- Assert return trade by position if pos>0
           if( pos>0 && count!= pos ) continue;
           
           msg = StringConcatenate(msg, strBotInt( "Ticket",OrderTicket() ));
           msg = StringConcatenate(msg, strBotStr( "Symbol",OrderSymbol() ));
           msg = StringConcatenate(msg, strBotInt( "Type",OrderType() ));
           msg = StringConcatenate(msg, strBotDbl( "Lots",OrderLots(),2 ));
           msg = StringConcatenate(msg, strBotDbl( "OpenPrice",OrderOpenPrice(),5 ));
           msg = StringConcatenate(msg, strBotDbl( "CurPrice",OrderClosePrice(),5 ));
           msg = StringConcatenate(msg, strBotDbl( "StopLoss",OrderStopLoss(),5 ));
           msg = StringConcatenate(msg, strBotDbl( "TakeProfit",OrderTakeProfit(),5 ));
           msg = StringConcatenate(msg, strBotTme( "OpenTime",OrderOpenTime() ));
           msg = StringConcatenate(msg, strBotTme( "CloseTime",OrderCloseTime() ));
           
        //--- Assert Partial Trade has comment="from #<historyTicket>"
           if( StringFind( OrderComment(), strPartial )>=0 )
              msg = StringConcatenate(msg, strBotStr( "PrevTicket", StringSubstr(OrderComment(),StringLen(strPartial)) ));
           else
              msg = StringConcatenate(msg, strBotStr( "PrevTicket", "0" ));
        }
     //--- Assert msg isnt empty
        if( msg=="" ) return( msg );   
        
     //--- Assert append count of trades
        if( pos>0 ) 
           msg = StringConcatenate(strBotInt( "Count",1 ), msg);
        else
           msg = StringConcatenate(strBotInt( "Count",count ), msg);
        return( msg );
     }
     string BotOrdersTicket(int ticket, bool noPending=true)
     {
        string msg=NL;
        const string strPartial="from #";
        int total=OrdersTotal();
     //--- Assert optimize function by checking total > 0
        if( total<=0 ) return( msg );
        
     //--- Assert determine history by ticket
        if( OrderSelect( ticket, SELECT_BY_TICKET, MODE_TRADES )==false ) return( msg );
        
     //--- Assert OrderType is either BUY or SELL if noPending=true
        if( noPending==true && OrderType() > 1 ) return( msg );
        
     //--- Assert OrderTicket is found
        msg = StringConcatenate(msg, strBotInt( "Ticket",OrderTicket() ));
        msg = StringConcatenate(msg, strBotStr( "Symbol",OrderSymbol() ));
        msg = StringConcatenate(msg, strBotInt( "Type",OrderType() ));
        msg = StringConcatenate(msg, strBotDbl( "Lots",OrderLots(),2 ));
        msg = StringConcatenate(msg, strBotDbl( "OpenPrice",OrderOpenPrice(),5 ));
        msg = StringConcatenate(msg, strBotDbl( "CurPrice",OrderClosePrice(),5 ));
        msg = StringConcatenate(msg, strBotDbl( "StopLoss",OrderStopLoss(),5 ));
        msg = StringConcatenate(msg, strBotDbl( "TakeProfit",OrderTakeProfit(),5 ));
        msg = StringConcatenate(msg, strBotTme( "OpenTime",OrderOpenTime() ));
        msg = StringConcatenate(msg, strBotTme( "CloseTime",OrderCloseTime() ));
     //--- Assert Partial Trade has comment="from #<historyTicket>"
        if( StringFind( OrderComment(), strPartial )>=0 )
           msg = StringConcatenate(msg, strBotStr( "PrevTicket", StringSubstr(OrderComment(),StringLen(strPartial)) ));
        else
           msg = StringConcatenate(msg, strBotStr( "PrevTicket", "0" ));
        return( msg );
     }
     string BotHistoryTicket(int ticket, bool noPending=true)
     {
        string msg=NL;
        const string strPartial="from #";
        int total=OrdersHistoryTotal();
     //--- Assert optimize function by checking total > 0
        if( total<=0 ) return( msg );   
     //--- Assert determine history by ticket
        if( OrderSelect( ticket, SELECT_BY_TICKET, MODE_HISTORY )==false ) return( msg );
        
     //--- Assert OrderType is either BUY or SELL if noPending=true
        if( noPending==true && OrderType() > 1 ) return( msg );
           
     //--- Assert OrderTicket is found
        msg = StringConcatenate(msg, strBotInt( "Ticket",OrderTicket() ));
        msg = StringConcatenate(msg, strBotStr( "Symbol",OrderSymbol() ));
        msg = StringConcatenate(msg, strBotInt( "Type",OrderType() ));
        msg = StringConcatenate(msg, strBotDbl( "Lots",OrderLots(),2 ));
        msg = StringConcatenate(msg, strBotDbl( "OpenPrice",OrderOpenPrice(),5 ));
        msg = StringConcatenate(msg, strBotDbl( "ClosePrice",OrderClosePrice(),5 ));
        msg = StringConcatenate(msg, strBotDbl( "StopLoss",OrderStopLoss(),5 ));
        msg = StringConcatenate(msg, strBotDbl( "TakeProfit",OrderTakeProfit(),5 ));
        msg = StringConcatenate(msg, strBotTme( "OpenTime",OrderOpenTime() ));
        msg = StringConcatenate(msg, strBotTme( "CloseTime",OrderCloseTime() ));
        
     //--- Assert Partial Trade has comment="from #<historyTicket>"
        if( StringFind( OrderComment(), strPartial )>=0 )
           msg = StringConcatenate(msg, strBotStr( "PrevTicket", StringSubstr(OrderComment(),StringLen(strPartial)) ));
        else
           msg = StringConcatenate(msg, strBotStr( "PrevTicket", "0" ));
        return( msg );
     }
     string BotOrdersHistoryTotal(bool noPending=true)
     {
        return( strBotInt( "Total", OrdersHistoryTotal() ) );
     }
     //|-----------------------------------------------------------------------------------------|
     //|                               A C C O U N T   S T A T U S                               |
     //|-----------------------------------------------------------------------------------------|
     string BotAccount(void)
     {
        string msg=NL;
        msg = StringConcatenate(msg, strBotInt( "Number",AccountNumber() ));
        msg = StringConcatenate(msg, strBotStr( "Currency",AccountCurrency() ));
        msg = StringConcatenate(msg, strBotDbl( "Balance",AccountBalance(),2 ));
        msg = StringConcatenate(msg, strBotDbl( "Equity",AccountEquity(),2 ));
        msg = StringConcatenate(msg, strBotDbl( "Margin",AccountMargin(),2 ));
        msg = StringConcatenate(msg, strBotDbl( "FreeMargin",AccountFreeMargin(),2 ));
        msg = StringConcatenate(msg, strBotDbl( "Profit",AccountProfit(),2 ));
        
        return( msg );
     }
```

![][3]

[3]: https://dennislwm.netlify.app/images/building-a-telegram-chat-with-a-mt4-forex-trading-expert-advisor/step-4---building-a-bot-query-tool.png

## Conclusion

In this tutorial, you used a Telegram Bot to query your orders from a Metatrader 4 client. You can use this approach to manage your order flow, view account details, open and close orders, or even broadcast trade signals to a Telegram group or channel.

## Get the Source Code

You can download the above source code from GitHub repository [MT4-Telegram-Bot-Recon](https://github.com/dennislwm/MT4-Telegram-Bot-Recon).

## What To Do Next

You can further extend your Bot in several meaningful ways:

1. Implementing Authentication - This is to ensure that only approved users have access to the Bot commands.
1. Implementing Open and Close Orders - This is to allow opening and closing orders using the Bot.
1. Implementing Modify SL and TP - This is to allow modifying the StopLoss and TakeProfit of an order.
1. Implementing Add and Delete Pending Orders - This is to manage pending orders using the Bot.
1. Create a Chart Query Tool: This is to allow users to query chart values, such as prices and indicator values for an instrument.
1. Broadcast Trading Signals in a Channel - This is to allow users to subscribe to your trade signals (one way communication).
1. Copy Trading Signal to a MT4 Client - This is to allow users to trade your signals automatically (requires a Client Bot).
