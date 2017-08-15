// Global JavaScript Variables
var DDG_option;
var ws;
var socket;
var isopen;
var wait_socket = 0;
var choose_name;
var myChart;
// For Utility


function validataOS() {
     console.log(navigator.userAgent);
     console.log(navigator.userAgent.indexOf('Windows'));
    if (navigator.userAgent.indexOf('Windows') > 0) {
        return 'Windows';
    } else if (navigator.userAgent.indexOf('Mac') > 0) {
        return 'Mac';
    } else if (navigator.userAgent.indexOf('Linux') > 0) {
        return 'Linux';
    } else {
        return 'NUll';
    }
   
}


function Jump(id, line) {
    if( validataOS() == 'Windows') {    
        var ta = document.getElementById(id);
        var lineHeight = ta.clientHeight / (ta.rows - 1);
        var jump = (line - 1) * lineHeight;
        ta.scrollTop = jump;
        console.log('W',jump,ta.clientHeight, ta.rows, lineHeight);        
    } else {
        var ta = document.getElementById(id);
        var lineHeight = ta.clientHeight / (ta.rows);
        var jump = (line - 1) * lineHeight;
        ta.scrollTop = jump;
        console.log('M', jump,ta.clientHeight, ta.rows, lineHeight, line);
    }
}

function readJSON(file) {
    var request = new XMLHttpRequest();
    request.open('GET', file, false);
    request.send(null);
    if (request.status == 200)
        return request.responseText;
};

function add_button(name) {
    //Create an input type dynamically.   
    var element = document.createElement("button");
    //Assign different attributes to the element. 
    element.setAttribute('class', 'list-group-item');
    element.setAttribute('value', name);
    element.setAttribute('id', name + "_database_button");
    element.innerHTML = name;

    element.onclick = function () { // Note this is a function
        database_button_click(name);
    };
    var foo = document.getElementById("list_group_database");
    foo.appendChild(element);
}

function add_tr_td(name, owner, size, time) {
    //Create an input type dynamically.   
    var element = document.createElement("tr");

    var n1 = document.createElement("td");
    n1.innerHTML = name;
    var n2 = document.createElement("td");
    n2.innerHTML = owner;
    var n3 = document.createElement("td");
    n3.innerHTML = size;
    var n4 = document.createElement("td");
    n4.innerHTML = time;
    element.appendChild(n1);
    element.appendChild(n2);
    element.appendChild(n3);
    element.appendChild(n4);

    var foo = document.getElementById("datasets_tbody");
    foo.appendChild(element);
}

// For Experiments.html : When Experiments.html is loaded, it's going to generate the dataset list items.
function list_files() {
    var s = readJSON('./database/database.json');
    s = JSON.parse(s);

    data = ""
    for (var i = 0; i < Object.keys(s).length; i++) {
        data += s[i].owner + s[i].file_name + s[i].built_up_time + s[i].size + "\n";
        add_button(s[i].file_name);
        console.log(s[i].file_name);
    }
    //document.getElementById('Textarea_Console').value = data;
    WebSocket_init();
    DDG_option_init();
    
}
function paddingLeft(str,lenght){
	if(str.length >= lenght)
	return str;
	else
	return paddingLeft(" " +str,lenght);
}


// When New HDL is seleted, it's going to update the dataset button state and load the rtl_textarea.
function database_button_click(name) {
    // update datasets list state
    var c = document.getElementById("list_group_database").children;
    for (var i = 0; i < c.length; i++)
        c[i].setAttribute('class', 'list-group-item');
    var foo = document.getElementById(name + "_database_button");
    foo.setAttribute('class', 'list-group-item active');

    // update rtl_textarea content
    var s = readJSON('./database/rtl/' + name);
    Jump('rtl_textarea', 0)
    var _line = s.split("\n");
    s ="";
    for (var i = 0; i < _line.length; i++) {
        _line[i] = paddingLeft((i+1).toString(),3) + " " + _line[i];
        s += _line[i] + "\n";
    }

    
    
    document.getElementById('rtl_textarea').value = s;
    document.getElementById('Textarea_Console').value = "";
    // update DDG content
    if (wait_socket == 0) {
        choose_name = name;
        socket.send(name);
        wait_socket = 1;
    }



}

//Page unload 
function page_unload() {　
    // Send null message to tell python server to close this connection! 
    socket.send("");
}


// For DDG setting and update
function DDG_run() {


    console.log("Echart setOption");
    console.log(choose_name);

    myChart.setOption(DDG_option);


}

function set_DDG_option(name) {

    var data_json = readJSON('./echarts_json/echarts_data.json');
    console.log("load option!!!!!!!");
    data_json = JSON.parse(data_json);
    var links_json = readJSON('./echarts_json/echarts_links.json');
    links_json = JSON.parse(links_json);
    console.log(data_json);
    //alert(JSON.stringify(DDG_option));
    if (name != "") {
        DDG_option.title.text = name + " DDG";
        DDG_option.title.name = name + " DDG";
    }


    DDG_option.series.data = data_json;
    for (var i = 0; i < Object.keys(data_json).length; i++) {
        DDG_option.series.data[i].tooltip = {
            show: true,
            trigger: 'item',
            formatter: function (params, ticket, callback) {
                //console.log(params)
                var res = params.data.value;
                //callback(ticket, res);
                return res;
            }
        }
    }
    if (Object.keys(data_json).length < 5) {
        DDG_option.series.symbolSize = [120, 70];
    } else if (Object.keys(data_json).length < 10) {
        DDG_option.series.symbolSize = [100, 40];
    } else {
        DDG_option.series.symbolSize = [70, 20];
    }
    DDG_option.series.links = links_json;


}


function WebSocket_init() {
    socket = new WebSocket("ws://140.112.171.145:7000");
    socket.binaryType = "arraybuffer";
    socket.onopen = function () {
        console.log("Connected!");
        isopen = true;
    }
    socket.onmessage = function (e) {
        if (typeof e.data == "string") {
            console.log("Text message received: " + e.data);
            document.getElementById('Textarea_Console').value += e.data + "\n";
            document.getElementById('Textarea_Console').scrollTop = document.getElementById('Textarea_Console').scrollHeight;
            //check message
            if (e.data == "Done!") {
                console.log("OKOK!");

                wait_socket = 0;
                set_DDG_option(choose_name);
                DDG_run();
                /*
                setTimeout(function () {
                    set_DDG_option(choose_name);
                    DDG_run();
                }, 200);
                */
            }
        } else {
            var arr = new Uint8Array(e.data);
            var hex = '';
            for (var i = 0; i < arr.length; i++) {
                hex += ('00' + arr[i].toString(16)).substr(-2);
            }
            console.log("Binary message received: " + hex);

        }
    }
    socket.onclose = function (e) {
        console.log("Connection closed.");
        socket = null;
        isopen = false;
    }
}

function DDG_option_init() {
    myChart = echarts.init(document.getElementById('DDG'));
    myChart.on('click', function (params) {
        console.log("mychar click trigger!!!");
        var value = params.data.value;
        value = value.split("<br>");
        value = value[3].split(" ");
        //console.log(params.data.value);
        //console.log(value);
        Jump('rtl_textarea', value[2]);
    });
    DDG_option = {
        title: {
            text: 'Drive Directed Graph'
        },
        name: '',
        focusNodeAdjacency: true,
        tooltip: {},
        animationDurationUpdate: 1500,
        animationEasingUpdate: 'quinticInOut',
        series: {
            type: 'graph',
            layout: 'none',

            roam: true,
            symbol: 'rect',
            symbolSize: [50, 35],
            label: {
                normal: {
                    show: true
                }
            },
            edgeSymbol: ['none', 'arrow'],
            edgeSymbolSize: [6, 10],
            edgeLabel: {
                normal: {
                    textStyle: {
                        fontSize: 15
                    }
                }
            },
            data: [],
            links: [],
            lineStyle: {
                normal: {
                    opacity: 0.9,
                    width: 2,
                    curveness: 0.0
                }
            }
        }

    };
}



// For Datasets.html : When Datasets.html is loaded, it's going to generate the dataset table items.
function update_datasets() {

    var s = readJSON('./database/database.json');
    s = JSON.parse(s);
    data = ""
    for (var i = 0; i < Object.keys(s).length; i++) {
        data += s[i].owner + s[i].file_name + s[i].built_up_time + s[i].size + "\n";
        add_tr_td(s[i].file_name, s[i].owner, s[i].size, s[i].built_up_time);
    }
    var foo = document.getElementById("datasets_number");
    foo.innerHTML = Object.keys(s).length;
}



