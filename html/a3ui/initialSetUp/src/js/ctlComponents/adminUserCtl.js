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

import adminUserImg from "../../media/adminUser.svg";



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
            passScore:{},
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
            newWrongMessage.userWrongMessage=self.state.i18n.emailIsRequired;
        }else
        if(isEmail(user.toString().trim())===false){
            newWrongMessage.userWrongMessage=self.state.i18n.emailFormatIsIncorrect;
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
            newWrongMessage.passWrongMessage=self.state.i18n.passwordIsRequired;
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

    onBlurCheckPassConfirm(e){
        let self=this;
        self.checkPassConfirm(e.target.value);
    }

    checkPassConfirm=(passConfirm)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!passConfirm||passConfirm.toString().trim()===""){
            newWrongMessage.passConfirmWrongMessage=self.state.i18n.confirmPasswordIsRequired;
        }else
        if(passConfirm.toString().trim()!==($("#pass").val()?$("#pass").val().toString().trim():"")){
            newWrongMessage.passConfirmWrongMessage=self.state.i18n.passwordDoNotMatch;
        }else{
            newWrongMessage.passConfirmWrongMessage="";
        }


        self.setState({
            wrongMessage:newWrongMessage
        })
        if(newWrongMessage.passConfirmWrongMessage===""){
            $("#passConfirm").css({
                "border":"1px solid #d9d9d9",
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
                console.log(values);
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

                let xCsrfToken="";
                let url= "/a3/api/v1/configurator/admin_user";
                
                let param={
                    user:values.user,
                    pass:values.pass,
                }

                new RequestApi('post',url,JSON.stringify(param),xCsrfToken,(data)=>{
                    if(data.code==="ok"){
                        self.props.changeStatus("networks");
                    }else{
                        message.destroy();
                        message.error(data.msg);
                    }

                }) 






            }
        });
        
    }

    onClickCancel = () => {
        let self=this;
        self.props.form.resetFields();
        
    }

    onChangePass=(e) =>{
        let self=this;
        console.log(zxcvbn(e.target.value));
        self.checkPass(e.target.value);
        self.setState({
            passScore:zxcvbn(e.target.value),
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
            passMessageHtml=<div className="form-item-wrong-div-adminUserCtl" >
                                {wrongMessage.passWrongMessage}
                             </div>                           
        }else
        if(passScore.score===0){
            passMessageHtml=<div className="form-item-pass-score-div-adminUserCtl" >
                                <div className="form-item-pass-score-0-div-adminUserCtl" >
                                    {self.state.i18n.veryWeak}
                                </div>  
                                <div className="form-item-pass-score-message-div-adminUserCtl" >
                                    {passScore.feedback.warning===""?passScore.feedback.suggestions[0]:passScore.feedback.warning}
                                </div> 
                                <div className="clear-float-div-common" ></div > 
                             </div>                           
        }else
        if(passScore.score===1){
            passMessageHtml=<div className="form-item-pass-score-div-adminUserCtl" >
                                <div className="form-item-pass-score-1-div-adminUserCtl" >
                                    Weak
                                </div>  
                                <div className="form-item-pass-score-message-div-adminUserCtl" >
                                    {passScore.feedback.warning===""?passScore.feedback.suggestions[0]:passScore.feedback.warning}
                                </div> 
                                <div className="clear-float-div-common" ></div > 
                             </div>                           
        }else
        if(passScore.score===2){
            passMessageHtml=<div className="form-item-pass-score-div-adminUserCtl" >
                                <div className="form-item-pass-score-2-div-adminUserCtl" >
                                    Average
                                </div>  
                                <div className="form-item-pass-score-message-div-adminUserCtl" >
                                    {passScore.feedback.warning===""?passScore.feedback.suggestions[0]:passScore.feedback.warning}
                                </div> 
                                <div className="clear-float-div-common" ></div > 
                             </div>                           
        }else
        if(passScore.score===3){
            passMessageHtml=<div className="form-item-pass-score-3-div-adminUserCtl" >
                                Strong
                            </div>                            
        }else
        if(passScore.score===4){
            passMessageHtml=<div className="form-item-pass-score-4-div-adminUserCtl" >
                                Very Strong
                            </div>                            
        }
        return (
            <div className="global-div-adminUserCtl">
                <div className="left-div-adminUserCtl">
                    <Guidance 
                        title={"Welcome to A3!"} 
                        content={["Please add your primary administrator's login credentials here and select a strong password. It is advisable to consider an email alias if a team of individuals will be administering this system."]} 
                    />
                    <div className="img-div-adminUserCtl">
                       <img src={adminUserImg} className="img-img-adminUserCtl" />
                    </div>
                    <div className="clear-float-div-common" ></div >
                </div>

                <div className="right-div-adminUserCtl">
                    
                    <Form onSubmit={self.handleSubmit.bind(self)}>
                    <div className="form-item-div-adminUserCtl">
                        <div className="form-item-title-div-adminUserCtl">
                            Admin Email
                        </div>
                        <div className="form-item-input-div-adminUserCtl">
                            {getFieldDecorator('user', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckUser.bind(self)}
                                maxLength={254}
                                />
                            )}
                        </div>
                        <div className="form-item-wrong-div-adminUserCtl" 
                        style={{display:wrongMessage.userWrongMessage===""?"none":"block"}}>
                                {wrongMessage.userWrongMessage}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="form-item-div-adminUserCtl">
                        <div className="form-item-title-div-adminUserCtl">
                            Password
                        </div>
                        <div className="form-item-input-div-adminUserCtl">
                            {getFieldDecorator('pass', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckPass.bind(self)}
                                onChange={self.onChangePass.bind(self)}
                                maxLength={254}
                                />

                                
                            )}
                        </div>
                        {passMessageHtml}
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="form-item-div-adminUserCtl">
                        <div className="form-item-title-div-adminUserCtl">
                            Confirm Password
                        </div>
                        <div className="form-item-input-div-adminUserCtl">
                            {getFieldDecorator('passConfirm', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckPassConfirm.bind(self)}
                                
                                />
                            )}
                        </div>
                        <div className="form-item-wrong-div-adminUserCtl" 
                        style={{display:wrongMessage.passConfirmWrongMessage===""?"none":"block"}}>
                                {wrongMessage.passConfirmWrongMessage}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="form-button-div-adminUserCtl">
                        <div className="form-button-next-div-adminUserCtl">
                            <Button 
                                type="primary" 
                                className="form-button-next-antd-button-adminUserCtl" 
                                htmlType="submit" 
                            >NEXT</Button>
                        </div>
                        <div className="form-button-cancel-div-adminUserCtl">
                            <Button 
                                className="form-button-cancel-antd-button-adminUserCtl" 
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



