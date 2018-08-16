import React from 'react';

import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio  ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum} from "../../libs/util";     
import '../../css/ctlComponents/getStartCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/getStartCtl";
import {i18n} from "../../i18n/ctlComponents/nls/getStartCtl";

import newDeploymentLogoImg from "../../media/newDeploymentLogo.svg";
import joinClusterLogoImg from "../../media/joinClusterLogo.svg";

const {Component} = React;

class getStartCtl extends Component {
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
            rightI18n=i18nfr;
        }else{
            rightI18n=i18n;
        }
        self.setState({
            i18n : rightI18n,
        })

    }
    render() {
        const {} = this.state;
        const {} = this.props;
        const { getFieldDecorator } = this.props.form;
        let self = this;
        message.config({
            duration: 10,
        });
        return (
            <div className="global-div-getStartCtl">
                <div className="new-deployment-div-getStartCtl">
                    <div className="new-deployment-logo-div-getStartCtl">
                        <img src={newDeploymentLogoImg} className="new-deployment-logo-img-getStartCtl" />
                    </div>
                    <div className="new-deployment-new-div-getStartCtl">
                        NEW
                    </div>
                    <div className="new-deployment-deployment-div-getStartCtl">
                        DEPLOYMENT
                    </div>
                    <div className="new-deployment-explain-div-getStartCtl">
                        Set up a new cluster or standalone
                    </div>
                    <div className="new-deployment-button-div-getStartCtl">
                        GET STARTED
                    </div>
                    <div className="clear-float-div-common" ></div >
                </div>
                <div className="join-cluster-div-getStartCtl">
                    <div className="join-cluster-logo-div-getStartCtl">
                        <img src={joinClusterLogoImg} className="join-cluster-logo-img-getStartCtl" />
                    </div>
                    <div className="join-cluster-new-div-getStartCtl">
                        JOIN
                    </div>
                    <div className="join-cluster-deployment-div-getStartCtl">
                        CLUSTER
                    </div>
                    <div className="join-cluster-explain-div-getStartCtl">
                        Join an existing cluster
                    </div>
                    <div className="join-cluster-button-div-getStartCtl">
                        GET STARTED
                    </div>
                    <div className="clear-float-div-common" ></div >
                </div>
                <div className="clear-float-div-common" ></div >
            </div>
            
        )
    }
}


export default Form.create()(getStartCtl);



