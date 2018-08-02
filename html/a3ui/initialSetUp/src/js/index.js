
import React from 'react';
import ReactDOM from 'react-dom';
import { LocaleProvider } from 'antd';
import { Tabs,message ,Button,Tree } from 'antd';
const TreeNode = Tree.TreeNode;
import '../css/index.css';
import Util from "../libs/util";

import * as mock from "../libs/mockData";
import GetStartCtl from './ctlComponents/getStartCtl';

import en_GB from 'antd/lib/locale-provider/en_GB';
import fr_FR from 'antd/lib/locale-provider/fr_FR';


const {Component} = React;
const TabPane = Tabs.TabPane;
class App extends Component {
    constructor(props) {
        super(props);
        this.state = {
            i18n:{},

        };
    }

    componentDidMount() {
        let self=this;
        self.getRightI18n();
    }

    getRightI18n= () => {
        let self=this;
        let localeForLicenseInfo=window.localStorage.getItem('getStart');
        let rightI18n;
        if(localeForLicenseInfo==="fr"){
            rightI18n=fr_FR;
        }else{
            rightI18n=en_GB;
        }
        self.setState({
            i18n : rightI18n,
        })

    }

    render() {
        const {i18n} = this.state;
        let self=this;
        return (
            <div className="app-div-index">
                <LocaleProvider locale={i18n}>
                    <GetStartCtl />
                </LocaleProvider>
            </div>

        );
    }
}

ReactDOM.render(
    
        <App/>
    
    ,document.getElementById('app')
);
