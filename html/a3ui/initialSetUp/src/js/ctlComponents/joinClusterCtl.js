import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio  ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail,isIp} from "../../libs/util";     
import '../../css/ctlComponents/joinClusterCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/joinClusterCtl";
import {i18n} from "../../i18n/ctlComponents/nls/joinClusterCtl";

import joinClusterImg from "../../media/joinCluster.png";



const {Component} = React;

class joinClusterCtl extends Component {
    constructor(props) {
        super(props);
        this.state = {
            i18n:{},
            wrongMessage:{
                primaryServerWrongMessage:"",
                adminWrongMessage:"",
                passwdWrongMessage:"",
                
            },
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

    onClickCancel = () => {
        let self=this;
        self.props.form.resetFields();
        
    }
    onBlurCheckPrimaryServer(e){
        let self=this;
        self.checkPrimaryServer(e.target.value);
    }

    checkPrimaryServer=(primaryServer)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!primaryServer||primaryServer.toString().trim()===""){
            newWrongMessage.primaryServerWrongMessage="Cluster Primary is required.";
        }else
        if(isIp(primaryServer.toString().trim())===false){
            newWrongMessage.primaryServerWrongMessage="Cluster Primary is incorret.";
        }else{
            newWrongMessage.primaryServerWrongMessage="";
        }


        self.setState({
            wrongMessage:newWrongMessage
        })
        if(newWrongMessage.primaryServerWrongMessage===""){
            $("#primary_server").css({
                "border":"1px solid #d9d9d9",
            });
            return true;
        }else{
            $("#primary_server").css({
                "border":"1px solid red",
            });
            
            return false;
        }
    }

    onBlurCheckAdmin(e){
        let self=this;
        self.checkAdmin(e.target.value);
    }

    checkAdmin=(admin)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!admin||admin.toString().trim()===""){
            newWrongMessage.adminWrongMessage="Cluster Admin is required";
        }else
        if(isEmail(admin.toString().trim())===false){
            newWrongMessage.adminWrongMessage="Email format is incorret.";
        }else{
            newWrongMessage.adminWrongMessage="";
        }


        self.setState({
            wrongMessage:newWrongMessage
        })
        if(newWrongMessage.adminWrongMessage===""){
            $("#admin").css({
                "border":"1px solid #d9d9d9",
            });
            return true;
        }else{
            $("#admin").css({
                "border":"1px solid red",
            });
            
            return false;
        }
    }

    onBlurCheckPasswd(e){
        let self=this;
        self.checkPasswd(e.target.value);
    }

    checkPasswd=(passwd)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!passwd||passwd.toString().trim()===""){
            newWrongMessage.passwdWrongMessage="Admin Password is required";
        }else{
            newWrongMessage.passwdWrongMessage="";
        }


        self.setState({
            wrongMessage:newWrongMessage
        })
        if(newWrongMessage.passwdWrongMessage===""){
            $("#passwd").css({
                "border":"1px solid #d9d9d9",
            });
            return true;
        }else{
            $("#passwd").css({
                "border":"1px solid red",
            });
            
            return false;
        }
    }

    handleSubmit = (e) => {
        let self=this;
        e.preventDefault();
        this.props.form.validateFields((err, values) => {
            if (!err) {
                let hasWrongValue=false;
                if(self.checkPasswd(values.passwd)===false){
                    hasWrongValue=true;
                    $("#passwd").focus();
                }
                if(self.checkAdmin(values.admin)===false){
                    hasWrongValue=true;
                    $("#admin").focus();
                }
                if(self.checkPrimaryServer(values.primary_server)===false){
                    hasWrongValue=true;
                    $("#primary_server").focus();
                }
                if(hasWrongValue===true){
                    return;
                }


            }
        });
        
    }



    render() {
        const {wrongMessage} = this.state;
        const {} = this.props;
        const { getFieldDecorator } = this.props.form;
        let self = this;
        message.config({
            duration: 10,
        });
        return (
            <div className="global-div-joinClusterCtl">
                <div className="left-div-joinClusterCtl">
                    <Guidance 
                        title={"Join Cluster"} 
                        content={"awgwaegWEE EEEEEEEEEE EEEEEEWfeWEFABERBAR WRBRAEBAERBBEABAWRBAERBAER BAEBABRAEBVAWRVAERBAERBAERBAERBAER BawgwaegWEEEE EEEEEEEEEEEEEEWfeWEFABERBA RWRBRAEBAERBBEABAWRBAE RBAERBAEB ABRAEBVAWR  VAERBAERBA ERBAERBAER BawgwaegWE EEEEEEEEEEE EEEEEEWfeWE FABERBARWRB RAEBAERBBEA BAWRBAER BAERBAEBAB RAEBVAWRVAERB AERBAERBAERBAERB ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"} 
                    />
                    <div className="img-div-joinClusterCtl">
                       <img src={joinClusterImg} className="img-img-joinClusterCtl" />
                    </div>
                    <div className="clear-float-div-common" ></div >
                </div>

                <div className="right-div-joinClusterCtl">
                    
                    <Form onSubmit={self.handleSubmit.bind(self)}>

                    <div className="form-item-div-joinClusterCtl">
                        <div className="form-item-title-div-joinClusterCtl">
                            Cluster Primary
                        </div>
                        <div className="form-item-input-div-joinClusterCtl">
                            {getFieldDecorator('primary_server', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckPrimaryServer.bind(self)}
                                
                                />
                            )}
                        </div>
                        <div className="form-item-wrong-div-joinClusterCtl" 
                        style={{display:wrongMessage.primaryServerWrongMessage===""?"none":"block"}}>
                                {wrongMessage.primaryServerWrongMessage}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>


                    <div className="form-item-div-joinClusterCtl">
                        <div className="form-item-title-div-joinClusterCtl">
                            Cluster Admin
                        </div>
                        <div className="form-item-input-div-joinClusterCtl">
                            {getFieldDecorator('admin', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckAdmin.bind(self)}
                                />
                            )}
                        </div>
                        <div className="form-item-wrong-div-joinClusterCtl" 
                        style={{display:wrongMessage.adminWrongMessage===""?"none":"block"}}>
                                {wrongMessage.adminWrongMessage}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="form-item-div-joinClusterCtl">
                        <div className="form-item-title-div-joinClusterCtl">
                            Admin Password
                        </div>
                        <div className="form-item-input-div-joinClusterCtl">
                            {getFieldDecorator('passwd', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckPasswd.bind(self)}
                                />

                                
                            )}
                        </div>
                        <div className="form-item-wrong-div-joinClusterCtl" 
                        style={{display:wrongMessage.passwdWrongMessage===""?"none":"block"}}>
                                {wrongMessage.passwdWrongMessage}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>



                    <div className="form-button-div-joinClusterCtl">
                        <div className="form-button-next-div-joinClusterCtl">
                            <Button 
                                type="primary" 
                                className="form-button-next-antd-button-joinClusterCtl" 
                                htmlType="submit" 
                            >NEXT</Button>
                        </div>
                        <div className="form-button-cancel-div-joinClusterCtl">
                            <Button 
                                className="form-button-cancel-antd-button-joinClusterCtl" 
                                onClick={self.onClickCancel.bind(self)}
                            >CANCEL</Button>
                        </div>
                    </div>



                    </Form>


              
                    <div className="clear-float-div-common" ></div >
                </div>

                <div className="clear-float-div-common" ></div >
            </div>
            
        )
    }
}


export default Form.create()(joinClusterCtl);



