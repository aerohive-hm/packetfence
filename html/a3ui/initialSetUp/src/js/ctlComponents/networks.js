import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio  ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail} from "../../libs/util";     
import '../../css/ctlComponents/adminUserCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/adminUserCtl";
import {i18n} from "../../i18n/ctlComponents/nls/adminUserCtl";

import adminUserImg from "../../media/adminUser.png";



const {Component} = React;

class adminUserCtl extends Component {
    constructor(props) {
        super(props);
        this.state = {
            i18n:{},
            wrongMessage:{
                userWrongMessage:"",
                passWrongMessage:"",
                passConfirmWrongMessage:"",
                
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

    onBlurCheckUser(e){
        let self=this;
        self.checkUser(e.target.value);
    }

    checkUser=(user)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!user||user.toString().trim()===""){
            newWrongMessage.userWrongMessage="Email is required.";
        }else
        if(isEmail(user)===false){
            newWrongMessage.userWrongMessage="Email format is incorrect.";
        }else{
            newWrongMessage.userWrongMessage="";
        }


        self.setState({
            wrongMessage:newWrongMessage
        })
        if(newWrongMessage.userWrongMessage===""){
            $("#user").css({
                "border":"1px solid #999999",
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
                "border":"1px solid #999999",
            });
            return true;
        }else{
            $("#pass").css({
                "border":"1px solid red",
            });
            
            return false;
        }
    }

    onBlurCheckPassConfirm(e){
        let self=this;
        self.checkPassConfirm(e.target.value);
    }

    checkPassConfirm=(passConfirm)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!passConfirm||passConfirm.toString().trim()===""){
            newWrongMessage.passConfirmWrongMessage="Confirm Password is required";
        }else
        if(passConfirm.toString().trim()!==($("#pass").val()?$("#pass").val().toString().trim():"")){
            newWrongMessage.passConfirmWrongMessage="Password do not match";
        }else{
            newWrongMessage.passConfirmWrongMessage="";
        }


        self.setState({
            wrongMessage:newWrongMessage
        })
        if(newWrongMessage.passConfirmWrongMessage===""){
            $("#passConfirm").css({
                "border":"1px solid #999999",
            });
            return true;
        }else{
            $("#passConfirm").css({
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
                if(self.checkPassConfirm(values.passConfirm)===false){
                    hasWrongValue=true;
                    $("#passConfirm").focus();
                }
                if(self.checkPass(values.pass)===false){
                    hasWrongValue=true;
                    $("#pass").focus();
                }
                if(self.checkUser(values.user)===false){
                    hasWrongValue=true;
                    $("#user").focus();
                }
                if(hasWrongValue===true){
                    return;
                }


            }
        });
        
    }

    onClickCancel = () => {
        let self=this;
        self.props.form.resetFields();
        
    }

    onChangePass=(e) =>{
        let self=this;
        console.log(zxcvbn(e.target.value).score);
        self.checkPass(e.target.value);
        self.setState({
            passScore:zxcvbn(e.target.value).score,
        })



    }






    render() {
        const {wrongMessage,passScore} = this.state;
        const {} = this.props;
        const { getFieldDecorator } = this.props.form;
        let self = this;
        message.config({
            duration: 10,
        });
        let passMessageHtml;
        if(wrongMessage.passWrongMessage!==""){
            passMessageHtml=<div className="form-item-wrong-div-radiusConfigurationCtl" >
                                {wrongMessage.passWrongMessage}
                             </div>                           
        }else
        if(passScore===0){
            passMessageHtml=<div className="form-item-pass-score-div-radiusConfigurationCtl" >
                                <div className="form-item-pass-score-0-div-radiusConfigurationCtl" >
                                    Very Weak
                                </div>  
                                <div className="form-item-pass-score-message-div-radiusConfigurationCtl" >
                                    Short keyboard patterns are easy to guess.
                                </div> 
                                <div className="clear-float-div-common" ></div > 
                             </div>                           
        }else
        if(passScore===1){
            passMessageHtml=<div className="form-item-pass-score-div-radiusConfigurationCtl" >
                                <div className="form-item-pass-score-1-div-radiusConfigurationCtl" >
                                    Weak
                                </div>  
                                <div className="form-item-pass-score-message-div-radiusConfigurationCtl" >
                                    Repeats like "aaa" are easy to guess.
                                </div> 
                                <div className="clear-float-div-common" ></div > 
                             </div>                           
        }else
        if(passScore===2){
            passMessageHtml=<div className="form-item-pass-score-div-radiusConfigurationCtl" >
                                <div className="form-item-pass-score-2-div-radiusConfigurationCtl" >
                                    Average
                                </div>  
                                <div className="form-item-pass-score-message-div-radiusConfigurationCtl" >
                                    Add another word or two. Uncommon words are better.
                                </div> 
                                <div className="clear-float-div-common" ></div > 
                             </div>                           
        }else
        if(passScore===3){
            passMessageHtml=<div className="form-item-pass-score-3-div-radiusConfigurationCtl" >
                                Strong
                            </div>                            
        }else
        if(passScore===4){
            passMessageHtml=<div className="form-item-pass-score-4-div-radiusConfigurationCtl" >
                                Very Strong
                            </div>                            
        }
        return (
            <div className="global-div-adminUserCtl">
                <div className="left-div-adminUserCtl">
                    <Guidance 
                        title={"Admin User"} 
                        content={"awgwaegWEE EEEEEEEEEE EEEEEEWfeWEFABERBAR WRBRAEBAERBBEABAWRBAERBAER BAEBABRAEBVAWRVAERBAERBAERBAERBAER BawgwaegWEEEE EEEEEEEEEEEEEEWfeWEFABERBA RWRBRAEBAERBBEABAWRBAE RBAERBAEB ABRAEBVAWR  VAERBAERBA ERBAERBAER BawgwaegWE EEEEEEEEEEE EEEEEEWfeWE FABERBARWRB RAEBAERBBEA BAWRBAER BAERBAEBAB RAEBVAWRVAERB AERBAERBAERBAERB ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"} 
                    />
                    <div className="img-div-adminUserCtl">
                       <img src={adminUserImg} className="img-img-adminUserCtl" />
                    </div>
                    <div className="clear-float-div-common" ></div >
                </div>

                <div className="right-div-adminUserCtl">
                    
                    <Form onSubmit={self.handleSubmit.bind(self)}>
                    <div className="form-item-div-radiusConfigurationCtl">
                        <div className="form-item-title-div-radiusConfigurationCtl">
                            Admin Email
                        </div>
                        <div className="form-item-input-div-radiusConfigurationCtl">
                            {getFieldDecorator('user', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckUser.bind(self)}
                                />
                            )}
                        </div>
                        <div className="form-item-wrong-div-radiusConfigurationCtl" 
                        style={{display:wrongMessage.userWrongMessage===""?"none":"block"}}>
                                {wrongMessage.userWrongMessage}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="form-item-div-radiusConfigurationCtl">
                        <div className="form-item-title-div-radiusConfigurationCtl">
                            Password
                        </div>
                        <div className="form-item-input-div-radiusConfigurationCtl">
                            {getFieldDecorator('pass', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckPass.bind(self)}
                                onChange={self.onChangePass.bind(self)}
                                />

                                
                            )}
                        </div>
                        {passMessageHtml}
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="form-item-div-radiusConfigurationCtl">
                        <div className="form-item-title-div-radiusConfigurationCtl">
                            Confirm Password
                        </div>
                        <div className="form-item-input-div-radiusConfigurationCtl">
                            {getFieldDecorator('passConfirm', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckPassConfirm.bind(self)}
                                
                                />
                            )}
                        </div>
                        <div className="form-item-wrong-div-radiusConfigurationCtl" 
                        style={{display:wrongMessage.passConfirmWrongMessage===""?"none":"block"}}>
                                {wrongMessage.passConfirmWrongMessage}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="form-button-div-radiusConfigurationCtl">
                        <div className="form-button-next-div-radiusConfigurationCtl">
                            <Button 
                                type="primary" 
                                className="form-button-next-antd-button-radiusConfigurationCtl" 
                                htmlType="submit" 
                            >NEXT</Button>
                        </div>
                        <div className="form-button-cancel-div-radiusConfigurationCtl">
                            <Button 
                                className="form-button-cancel-antd-button-radiusConfigurationCtl" 
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


export default Form.create()(adminUserCtl);



