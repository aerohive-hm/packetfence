
import React from 'react';
import ReactDOM from 'react-dom';
import { LocaleProvider } from 'antd';
import { Tabs,message ,Button,Tree,Spin } from 'antd';
const TreeNode = Tree.TreeNode;
import '../css/index.css';
import {RequestApi} from "../libs/util";

import * as mock from "../libs/mockData";
import GetStartCtl from './ctlComponents/getStartCtl';
import AdminUserCtl from './ctlComponents/adminUserCtl';
import NetworksCtl from './ctlComponents/networksCtl';
import ClusterNetworkingCtl from './ctlComponents/clusterNetworkingCtl';
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
            loading : false,
            show:"",
            // getStart
            // adminUser
            // networks
            // aerohiveCloud
            // joinCluster
            // licensing
            // licensing,enterEntitlementKey
            // licensing,endUserLicenseAgreement
            // startingManagement
            // startingRegistration
            // joining
            // clusterNetworking
        };
    }

    componentDidMount() {
        let self=this;
        self.getRightI18n();
        
    }

    getRightI18n= () => {
        let self=this;

        let navigatorLanguage = navigator.language||navigator.userLanguage;
        navigatorLanguage = navigatorLanguage.substr(0, 2);
        console.log("navigatorLanguage:"+navigatorLanguage);
        let rightI18n;
        if(navigatorLanguage==="fr"){
            rightI18n=fr_FR;
        }else{
            rightI18n=en_GB;
        }
        self.setState({
            i18n : rightI18n,
            navigatorLanguage:navigatorLanguage,
        },function(){
            self.getStep();
        })

    }



    getStep= () => {
        let self=this;

        let xCsrfToken="";
        let url= "/a3/api/v1/configurator/step?timestamp="+new Date().getTime();
         
        let param={
        }
        
        self.setState({
            loading : true,
        })

        new RequestApi('get',url,param,xCsrfToken,(data)=>{
            self.setState({
                loading : false,
                show:data.step,
            })
        },()=>{
            self.setState({
                loading : false,
            })

        });

    }

    changeStatus(show){
        let self=this;
        self.setState({
            show:show,
        })
    }

    render() {
        const {i18n,show,loading,navigatorLanguage} = this.state;
        let self=this;

        let contentHtml;
        if(show==="getStart"){
            contentHtml=<div>
                <GetStartCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                    navigatorLanguage={navigatorLanguage}
                />
            </div>
        }else if(show==="adminUser"){
            contentHtml=<div>
                <AdminUserCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                    navigatorLanguage={navigatorLanguage}
                />
            </div>
        }else if(show==="networks"){
            contentHtml=<div>
                <NetworksCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                    navigatorLanguage={navigatorLanguage}
                />
            </div>
        }else if(show==="aerohiveCloud"){
            contentHtml=<div>
                <AerohiveCloudCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                    navigatorLanguage={navigatorLanguage}
                />
            </div>
        }else if(show==="joinCluster"){
            contentHtml=<div>
                <JoinClusterCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                    navigatorLanguage={navigatorLanguage}
                />
            </div>
        }else if(show==="licensing"||show==="licensing,enterEntitlementKey"||show==="licensing,endUserLicenseAgreement"){
            contentHtml=<div>
                <LicensingCtl 
                    show={show}
                    changeStatus={self.changeStatus.bind(self)} 
                    navigatorLanguage={navigatorLanguage}
                />
            </div>
        }else if(show==="startingManagement"){
            contentHtml=<div>
                <StartingCtl 
                    title={"Initial setup complete!"}
                    changeStatus={self.changeStatus.bind(self)} 
                    navigatorLanguage={navigatorLanguage}
                />
            </div>
        }else if(show==="startingRegistration"){
            contentHtml=<div>
                <StartingCtl 
                    title={"Successfully joined cluster!"}
                    changeStatus={self.changeStatus.bind(self)} 
                    navigatorLanguage={navigatorLanguage}
                />
            </div>
        }else if(show==="joining"){
            contentHtml=<div>
                <JoiningCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                    navigatorLanguage={navigatorLanguage}
                />
            </div>
        }else if(show==="clusterNetworking"){
            contentHtml=<div>
                <ClusterNetworkingCtl 
                    changeStatus={self.changeStatus.bind(self)} 
                    navigatorLanguage={navigatorLanguage}
                />
            </div>
        }

        return (
            <LocaleProvider locale={i18n}>
            <div className="app-div-index">
                <Spin spinning={loading}>
                <Logo 
                    navigatorLanguage={navigatorLanguage}
                />
                <div className="content-div-index" >
                    {contentHtml}
                </div>
                </Spin>
            </div>
            </LocaleProvider>

        );
    }
}

ReactDOM.render(
    
        <App/>
    
    ,document.getElementById('app')
);