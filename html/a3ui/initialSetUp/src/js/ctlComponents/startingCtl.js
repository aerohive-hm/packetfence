import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio ,Progress ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail} from "../../libs/util";     
import '../../css/ctlComponents/startingCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/startingCtl";
import {i18n} from "../../i18n/ctlComponents/nls/startingCtl";

import startingAndReadyImg from "../../media/startingAndReady.svg";



const {Component} = React;

class startingCtl extends Component {
    constructor(props) {
        super(props);
        this.state = {
            i18n:{},
            loading:true,
            percentage:0,
        };
        


    }
    

    componentDidMount() {
        let self=this;
        self.getRightI18n();

        let url = "/api/v1/configurator/services/status";
        let param={
        }
        let xCsrfToken="";

        self.setState({
            loading:true,
        }) 

        this.timer = setInterval(()=>{

            RequestApi('get',url,param,xCsrfToken,(data)=>{
                if(data.code==="ok"){
                    if(data.percentage==="100"){
                        clearInterval(self.timer);
                        self.setState({
                            percentage : 0,
                            loading:false,
                        })
                    }else{
                        self.setState({
                            percentage : parseInt(data.percentage),
                        }) 
                    }  
                }else{
                    message.destroy();
                    message.error(data.msg);
                }

            });

        },3000)


    }

    componentWillUnmount(){
        clearInterval(this.timer)
        this.timer = null

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
        const {loading,percentage} = this.state;
        const {title} = this.props;
        const { getFieldDecorator } = this.props.form;
        let self = this;
        message.config({
            duration: 10,
        });
     
        let contentHtml;
        if(loading===false){
            contentHtml=<div className="right-content-div-startingCtl">
                            <div className="a3-started-successfully-div-startingCtl">
                                A3 has started successfully
                            </div>
                            <div className="go-to-div-startingCtl">
                                <Button 
                                    type="primary" 
                                    className="go-to-antd-button-startingCtl" 
                                >GO TO ADMINISTRATION INTERFACE</Button>
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>
        }else{
            contentHtml=<div className="right-content-div-startingCtl">
                            <div className="a3-starting-up-div-startingCtl">
                                A3 services are now starting up...
                            </div>
                            <div className="progress-div-startingCtl">
                                <Progress percent={percentage} />
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>

        }

        return (
            <div className="global-div-startingCtl">
                <div className="left-div-startingCtl">
                    <div className="img-div-startingCtl">
                       <img src={startingAndReadyImg} className="img-img-startingCtl" />
                    </div>
                </div>
                <div className="right-div-startingCtl">
                    <div className="right-title-div-startingCtl">
                        {title}
                    </div>
                    {contentHtml}

                    <div className="clear-float-div-common" ></div >
                </div>
                



                <div className="clear-float-div-common" ></div >
            </div>
            
        )
    }
}


export default Form.create()(startingCtl);



