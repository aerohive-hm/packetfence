import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio  ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail} from "../../libs/util";     
import '../../css/ctlComponents/aerohiveCloudCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/aerohiveCloudCtl";
import {i18n} from "../../i18n/ctlComponents/nls/aerohiveCloudCtl";

import aerohiveCloudImg from "../../media/aerohiveCloud.png";



const {Component} = React;

class aerohiveCloudCtl extends Component {
    constructor(props) {
        super(props);
        this.state = {
            i18n:{},
            wrongMessage:{
                urlWrongMessage:"",
                userWrongMessage:"",
                passWrongMessage:"",
                
            },
            passScore:-1
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

   
    onClickCreateAnAerohiveCloudAccount=()=>{
        let self=this;
        window.open("https://www.aerohive.com/cloud-networking");
    }

    onBlurCheckUrl(e){
        let self=this;
        self.checkUrl(e.target.value);
    }

    checkUrl=(url)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!url||url.toString().trim()===""){
            newWrongMessage.urlWrongMessage="Cloud URL is required.";
        }else{
            newWrongMessage.urlWrongMessage="";
        }


        self.setState({
            wrongMessage:newWrongMessage
        })
        if(newWrongMessage.urlWrongMessage===""){
            $("#url").css({
                "border":"1px solid #d9d9d9",
            });
            return true;
        }else{
            $("#url").css({
                "border":"1px solid red",
            });
            
            return false;
        }
    }

    onBlurCheckUser(e){
        let self=this;
        self.checkUser(e.target.value);
    }

    checkUser=(user)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!user||user.toString().trim()===""){
            newWrongMessage.userWrongMessage="Cloud Admin User is required";
        }else{
            newWrongMessage.userWrongMessage="";
        }


        self.setState({
            wrongMessage:newWrongMessage
        })
        if(newWrongMessage.userWrongMessage===""){
            $("#user").css({
                "border":"1px solid #d9d9d9",
            });
            return true;
        }else{
            $("#user").css({
                "border":"1px solid red",
            });
            
            return false;
        }
    }

    onBlurCheckPass(e){
        let self=this;
        self.checkPass(e.target.value);
    }

    checkPass=(pass)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!pass||pass.toString().trim()===""){
            newWrongMessage.passWrongMessage="Password is required";
        }else{
            newWrongMessage.passWrongMessage="";
        }


        self.setState({
            wrongMessage:newWrongMessage
        })
        if(newWrongMessage.passWrongMessage===""){
            $("#pass").css({
                "border":"1px solid #d9d9d9",
            });
            return true;
        }else{
            $("#pass").css({
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
                if(self.checkPass(values.pass)===false){
                    hasWrongValue=true;
                    $("#pass").focus();
                }
                if(self.checkUser(values.user)===false){
                    hasWrongValue=true;
                    $("#user").focus();
                }
                if(self.checkUrl(values.url)===false){
                    hasWrongValue=true;
                    $("#url").focus();
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
            <div className="global-div-aerohiveCloudCtl">
                <div className="left-div-aerohiveCloudCtl">
                    <Guidance 
                        title={"Aerohive Cloud"} 
                        content={"awgwaegWEE EEEEEEEEEE EEEEEEWfeWEFABERBAR WRBRAEBAERBBEABAWRBAERBAER BAEBABRAEBVAWRVAERBAERBAERBAERBAER BawgwaegWEEEE EEEEEEEEEEEEEEWfeWEFABERBA RWRBRAEBAERBBEABAWRBAE RBAERBAEB ABRAEBVAWR  VAERBAERBA ERBAERBAER BawgwaegWE EEEEEEEEEEE EEEEEEWfeWE FABERBARWRB RAEBAERBBEA BAWRBAER BAERBAEBAB RAEBVAWRVAERB AERBAERBAERBAERB ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"} 
                    />
                    <div className="img-div-aerohiveCloudCtl">
                       <img src={aerohiveCloudImg} className="img-img-aerohiveCloudCtl" />
                    </div>
                    <div className="clear-float-div-common" ></div >
                </div>

                <div className="right-div-aerohiveCloudCtl">
                    
                    <Form onSubmit={self.handleSubmit.bind(self)}>

                    <div className="form-item-div-aerohiveCloudCtl">
                        <div className="form-item-title-div-aerohiveCloudCtl">
                            Cloud URL
                        </div>
                        <div className="form-item-input-div-aerohiveCloudCtl">
                            {getFieldDecorator('url', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckUrl.bind(self)}
                                
                                />
                            )}
                        </div>
                        <div className="form-item-wrong-div-aerohiveCloudCtl" 
                        style={{display:wrongMessage.urlWrongMessage===""?"none":"block"}}>
                                {wrongMessage.urlWrongMessage}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>


                    <div className="form-item-div-aerohiveCloudCtl">
                        <div className="form-item-title-div-aerohiveCloudCtl">
                            Cloud Admin User
                        </div>
                        <div className="form-item-input-div-aerohiveCloudCtl">
                            {getFieldDecorator('user', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckUser.bind(self)}
                                />
                            )}
                        </div>
                        <div className="form-item-wrong-div-aerohiveCloudCtl" 
                        style={{display:wrongMessage.userWrongMessage===""?"none":"block"}}>
                                {wrongMessage.userWrongMessage}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="form-item-div-aerohiveCloudCtl">
                        <div className="form-item-title-div-aerohiveCloudCtl">
                            Password
                        </div>
                        <div className="form-item-input-div-aerohiveCloudCtl">
                            {getFieldDecorator('pass', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckPass.bind(self)}
                                />

                                
                            )}
                        </div>
                        <div className="form-item-wrong-div-aerohiveCloudCtl" 
                        style={{display:wrongMessage.passWrongMessage===""?"none":"block"}}>
                                {wrongMessage.passWrongMessage}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>



                    <div className="form-button-div-aerohiveCloudCtl">
                        <div className="form-button-link-div-aerohiveCloudCtl">
                            <Button 
                                type="primary" 
                                className="form-button-link-antd-button-aerohiveCloudCtl" 
                                htmlType="submit" 
                            >LINK WITH AEROHIVE CLOUD ACCOUNT</Button>
                        </div>
                    </div>
                    <div className="form-button-div-aerohiveCloudCtl">
                        <div className="form-button-create-div-aerohiveCloudCtl">
                            <Button 
                                className="form-button-create-antd-button-aerohiveCloudCtl" 
                                onClick={self.onClickCreateAnAerohiveCloudAccount.bind(self)}
                                
                            >CREATE AN AEROHIVE CLOUD ACCOUNT</Button>
                        </div>
                    </div>
                    <div className="form-button-continue-div-aerohiveCloudCtl">
                        Continue without an Aerohive Cloud Account
                    </div>



                    </Form>


              
                    <div className="clear-float-div-common" ></div >
                </div>

                <div className="clear-float-div-common" ></div >
            </div>
            
        )
    }
}


export default Form.create()(aerohiveCloudCtl);



