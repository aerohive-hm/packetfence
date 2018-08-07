
import React from 'react';
import ReactDOM from 'react-dom';
import { LocaleProvider } from 'antd';
import { Tabs,message ,Button,Tree } from 'antd';
const TreeNode = Tree.TreeNode;
import '../css/index.css';
import Util from "../libs/util";

import * as mock from "../libs/mockData";
import GetStartCtl from './ctlComponents/getStartCtl';
import AdminUserCtl from './ctlComponents/adminUserCtl';
import NetworksCtl from './ctlComponents/networksCtl';
import AerohiveCloudCtl from './ctlComponents/aerohiveCloudCtl';
import JoinClusterCtl from './ctlComponents/joinClusterCtl';
import LicensingCtl from './ctlComponents/licensingCtl';
import StartingCtl from './ctlComponents/startingCtl';
import JoiningCtl from './ctlComponents/joiningCtl';

import Logo from "../libs/logo/js/logo";

import en_GB from 'antd/lib/locale-provider/en_GB';
import fr_FR from 'antd/lib/locale-provider/fr_FR';


const {Component} = React;
const TabPane = Tabs.TabPane;
class App extends Component {
    constructor(props) {
        super(props);
        this.state = {
            i18n:{},
            show:"joinCluster",

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

    changeStatus(show){
        let self=this;
        self.setState({
            show:show,
        })
    }

    render() {
        const {i18n,show} = this.state;
        let self=this;

        let contentHtml;
        if(show==="getStart"){
            contentHtml=<div>
                <GetStartCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                />
            </div>
        }else if(show==="adminUser"){
            contentHtml=<div>
                <AdminUserCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                />
            </div>
        }else if(show==="networks"){
            contentHtml=<div>
                <NetworksCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                />
            </div>
        }else if(show==="aerohiveCloud"){
            contentHtml=<div>
                <AerohiveCloudCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                />
            </div>
        }else if(show==="joinCluster"){
            contentHtml=<div>
                <JoinClusterCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                />
            </div>
        }else if(show==="licensing"){
            contentHtml=<div>
                <LicensingCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                />
            </div>
        }else if(show==="startingManagement"){
            contentHtml=<div>
                <StartingCtl 
                    title={"Initial setup complete!"}
                    changeStatus={self.changeStatus.bind(self)} 
                />
            </div>
        }else if(show==="startingRegistration"){
            contentHtml=<div>
                <StartingCtl 
                    title={"Successfully joined cluster!"}
                    changeStatus={self.changeStatus.bind(self)} 
                />
            </div>
        }else if(show==="joining"){
            contentHtml=<div>
                <JoiningCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                />
            </div>
        }

        return (
            <LocaleProvider locale={i18n}>
            <div className="app-div-index">
                <Logo />
                <div className="content-div-index" >
                    {contentHtml}
                </div>
            </div>
            </LocaleProvider>

        );
    }
}

ReactDOM.render(
    
        <App/>
    
    ,document.getElementById('app')
);
