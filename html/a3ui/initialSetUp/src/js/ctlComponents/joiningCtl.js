import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio ,Progress ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail} from "../../libs/util";     
import '../../css/ctlComponents/joiningCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/joiningCtl";
import {i18n} from "../../i18n/ctlComponents/nls/joiningCtl";

import startingAndReadyImg from "../../media/startingAndReady.svg";



const {Component} = React;

class joiningCtl extends Component {
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

        let url = "/a3/api/v1/configurator/cluster/status";
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
                        },function(){
                            self.props.changeStatus("startingRegistration");
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

        },10000)


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
        const {} = this.props;
        const { getFieldDecorator } = this.props.form;
        let self = this;
        message.config({
            duration: 10,
        });

        return (
            <div className="global-div-joiningCtl">
                <div className="left-div-joiningCtl">
                    <div className="img-div-joiningCtl">
                       <img src={startingAndReadyImg} className="img-img-joiningCtl" />
                    </div>
                </div>
                <div className="right-div-joiningCtl">
                
                    <div className="joining-cluster-div-joiningCtl">
                        {self.state.i18n.joiningCluster}
                    </div>
                    <div className="progress-div-joiningCtl">
                        <Progress percent={percentage} />
                    </div>
            
           

                    <div className="clear-float-div-common" ></div >
                </div>
                



                <div className="clear-float-div-common" ></div >
            </div>
            
        )
    }
}


export default Form.create()(joiningCtl);



