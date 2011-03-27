// ==UserScript==
// @name           CPAN Vote
// @namespace      http://babyl.ca/cpanvote
// @include        http://search.cpan.org/*
// @require        http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js
// ==/UserScript==

var cpanvote_url = "http://cpanvote.metacpan.org";
var first_vote_grab = true;
var dist;

// looks like a dist page?
if ( $('td:contains("This Release")').length > 0 ) {
    dist = $('h1').text();

    dist = dist.replace( /-[v0-9][^-]*$/, "" );

    gm_xhr_bridge();

    $( function(){ 
        var rating_div = $($.grep( $('tr'), function(n,i){ 
            return $(n).find('td').text().match( /Rating/ ) })[0]
        );

        rating_div.after( 
            "<tr><td class='label'>CPAN Votes</td>"
        + "<td class='cell' colspan='3'><div style='display: inline-block' id='cpanvotes'>"
        + "<div class='votes'>"
        + "<div class='vote_tally' id='cpanvotes_yea'></div>"
        + "<div class='vote_tally' id='cpanvotes_meh'></div>"
        + "<div class='vote_tally' id='cpanvotes_nay'></div>"
        + "</div> "
        + "<div class='recommends'></div>"
        + "</div>" 
        + "<div id='voting_station'></div>"
        + "</td></tr>"
        );

        $('.vote_tally').css({
            width: "40px",
            'padding-right': '20px',
            'text-align': 'right',
            'background-position': 'right center',
            'background-repeat': 'no-repeat',
            'display': 'inline-block'
        });

        $('#cpanvotes_yea').css({
            'background-image':  "url("+cpanvote_url + "/static/images/yea.png)"
        });
        $('#cpanvotes_nay').css({
            'background-image':  "url("+cpanvote_url + "/static/images/nay.png)"
        });
        $('#cpanvotes_meh').css({
            'background-image':  "url("+cpanvote_url + "/static/images/meh.png)"
        });

        get_votes();
        get_instead();
    });

}

function get_votes () {

    $.getJSON(
        cpanvote_url + '/dist/' + dist + '/votes', 
        function(data) {
            $('#cpanvotes_yea').html( data["yea"] );
            $('#cpanvotes_nay').html( data["nay"] );
            $('#cpanvotes_meh').html( data["meh"] );

            if ( first_vote_grab ) {
                prepare_voting(dist,data);
            }

        } 
    );
}

function get_instead () {
    $.getJSON(
        cpanvote_url + '/dist/' + dist + '/instead', 
        function(data) {
            var dists = "dists" in data ? data["dists"] : new Array();

            var text = "";
            var dist_url = 'http://search.cpan.org/dist/';

            if ( dists.length > 0 ) {
                text = "peeps recommend instead : ";

                for ( var i = 0; i < dists.length; i++ ) {
                    if ( i > 0 ) {
                        text += ', ';
                    }
                    text += "<a href='" + dist_url + '/' + dists[i].distname 
                            + "'>" + dists[i].distname + "</a>";
                }
            }

            $('#cpanvotes .recommends').html( text );
        } 
    );

}

function prepare_voting (dist,data) {
    first_vote_grab = false;

    if ( !("my_vote" in data ) ) {
        $( '#voting_station' ).html(
                "authenticate yourself " 
                + "<a href='" + cpanvote_url + "/auth/twitter'>"
                + "via Twitter to vote</a>"
            );
    }
    else {
        var form_url = cpanvote_url + '/dist/' + dist + '/vote';

        $( '#voting_station' ).html(
             "your vote: <img src='" + cpanvote_url + "/static/images/yea_off.png' alt='yea' />"
           + "<img src='" + cpanvote_url + "/static/images/meh_off.png' alt='meh' />"
           + "<img src='" + cpanvote_url + "/static/images/nay_off.png' alt='nay' />"
        ).css({ height: '24px',
            "display": "inline-block",
            "margin-left": "20px"
            })
            .find('img').css({ padding: "4px", 
            "background-position": "center", "background-repeat": "no-repeat"})
        .hover( 
            function(){ $(this).css('background-image', "url(" +cpanvote_url + "/static/images/selected_vote.png)")  }, 
            function(){  $(this).css('background-image','')} )
        .click( function() {
            var $x = $(this);
            $.ajax({
                url: form_url + '/' + $x.attr('alt'),
                type: 'PUT',
                dataType: 'json',
                success: function() { 
                    $('#voting_station img').each(function(){
                        $(this).attr( 'src', 
                            $(this).attr('src').replace(/(_off)?\.png/, '_off.png') 
                            );
                    });
                    $x.attr( 'src', $x.attr('src').replace(/_off/, '' ) );

                    get_votes(); 
                }
            });
                });


        if ( data["my_vote"] != undefined ) {
            var $img = $('#voting_station img[alt="' + data["my_vote"] + '"]');
            $img.attr( 'src', $img.attr('src').replace( /_off/, '' ) );
        }

        var instead_form_url = cpanvote_url + '/dist/' + dist + '/instead/use';
        $('#voting_station').append(
                '<form style="display: inline-block" id="instead_form" action="' 
                + instead_form_url + '">'
                + 'instead, use <input id="instead" name="instead" />'
                + '<input type="submit" value="submit" id="instead_submit" />'
                + '</form>'
        );

        $('#instead_form').submit(function(){ submit_instead(); return false; } );
    }
} 

function submit_instead() {
    var form = $('#instead_form');

    var instead = form.find('#instead').val().replace( /::/g, '-' );

    if ( instead == "" ) {
        return;
    }

    var url = form.attr('action');

    $.ajax({
        url: form.attr('action') + '/' + instead,
        type: 'PUT',
        dataType: 'json',
        success: function() { 
            get_instead();
            // ... 
        }
    });

}


// Wrapper function
function GM_XHR() {
    this.type = null;
    this.url = null;
    this.async = null;
    this.username = null;
    this.password = null;
    this.status = null;
    this.headers = {};
    this.readyState = null;
    
    this.open = function(type, url, async, username, password) {
        this.type = type ? type : null;
        this.url = url ? url : null;
        this.async = async ? async : null;
        this.username = username ? username : null;
        this.password = password ? password : null;
        this.readyState = 1;
    };
    
    this.setRequestHeader = function(name, value) {
        this.headers[name] = value;
    };
        
    this.abort = function() {
        this.readyState = 0;
    };
    
    this.getResponseHeader = function(name) {
        return this.headers[name];
    };
    
    this.send = function(data) {
        this.data = data;
        var that = this;
        GM_xmlhttpRequest({
            method: this.type,
            url: this.url,
            headers: this.headers,
            data: this.data,
            onload: function(rsp) {
                // Populate wrapper object with all data returned from GM_XMLHttpRequest
                for (k in rsp) {
                    that[k] = rsp[k];
                }
            },
            onerror: function(rsp) {
                for (k in rsp) {
                    that[k] = rsp[k];
                }
            },
            onreadystatechange: function(rsp) {
                for (k in rsp) {
                    that[k] = rsp[k];
                }
            }
        });
    };
};
function gm_xhr_bridge() {
// Author: Ryan Greenberg (ryan@ischool.berkeley.edu)
// Date: September 3, 2009
// Version: $Id: gm_jq_xhr.js 240 2009-11-03 17:38:40Z ryan $

// This allows jQuery to make cross-domain XHR by providing
// a wrapper for GM_xmlhttpRequest. The difference between
// XMLHttpRequest and GM_xmlhttpRequest is that the Greasemonkey
// version fires immediately when passed options, whereas the standard
// XHR does not run until .send() is called. In order to allow jQuery
// to use the Greasemonkey version, we create a wrapper object, GM_XHR,
// that stores any parameters jQuery passes it and then creates GM_xmlhttprequest
// when jQuery calls GM_XHR.send().

// Tell jQuery to use the GM_XHR object instead of the standard browser XHR
$.ajaxSetup({
    xhr: function(){return new GM_XHR;}
});
}
