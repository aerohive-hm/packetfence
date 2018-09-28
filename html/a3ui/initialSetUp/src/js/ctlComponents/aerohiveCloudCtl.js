import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio  ,Select,Spin,Tooltip ,Popover,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail,isUrl} from "../../libs/util";     
import '../../css/ctlComponents/aerohiveCloudCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/aerohiveCloudCtl";
import {i18n} from "../../i18n/ctlComponents/nls/aerohiveCloudCtl";

import aerohiveCloudImg from "../../media/aerohiveCloud.svg";



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
            passScore:-1,
            loading:false,
        };

    }
    

    componentDidMount() {
        let self=this;
        self.getRightI18n();
    }

    getRightI18n= () => {
        let self=this;
        let navigatorLanguage = self.props.navigatorLanguage; 
        let rightI18n;
        if(navigatorLanguage==="fr"){
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

        const url = {
            cloudNetworking:"https://www.aerohive.com/cloud-networking",
        }

        window.open(url.cloudNetworking);
    }

    onBlurCheckUrl(e){
        let self=this;
        self.checkUrl(e.target.value);
    }

    checkUrl=(url)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!url||url.toString().trim()===""){
            newWrongMessage.urlWrongMessage=self.state.i18n.cloudUrlIsRequired;
        }else
        if(isUrl(url.toString().trim())===false){
            newWrongMessage.urlWrongMessage=self.state.i18n.cloudUrlMustStartWith;
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
            newWrongMessage.userWrongMessage=self.state.i18n.cloudAdminUserIsRequired;
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


                let xCsrfToken="";
                let url= "/a3/api/v1/configurator/cloud";
                
                let param={
                    url:values.url.trim(),
                    user:values.user.trim(),
                    pass:values.pass,
                }
                self.setState({
                    loading : true,
                })
                new RequestApi('post',url,JSON.stringify(param),xCsrfToken,(data)=>{
                    if(data.code==="ok"){
                        self.setState({
                            loading : false,
                        },function(){
                            self.props.changeStatus("startingManagement");
                        })
                        
                    }else{
                        self.setState({
                            loading : false,
                        })
                        message.destroy();
                        message.error(data.msg);
                    }

                },()=>{
                    self.setState({
                        loading : false,
                    })

                }) 


            }
        });
        
    }

    onClickContinueWithoutAnAerohiveCloudAccount= () => {
        let self=this;

        let xCsrfToken="";
        let url= "/a3/api/v1/configurator/cloud";
        
        let param={
            url:"",
        }
        self.setState({
            loading : true,
        })
        new RequestApi('post',url,JSON.stringify(param),xCsrfToken,(data)=>{
            if(data.code==="ok"){
                self.setState({
                    loading : false,
                },function(){
                    self.props.changeStatus("startingManagement");
                })
                
            }else{
                self.setState({
                    loading : false,
                })
                message.destroy();
                message.error(data.msg);
            }

        },()=>{
            self.setState({
                loading : false,
            })

        }) 
        
    }



    render() {
        const {wrongMessage,loading} = this.state;
        const {} = this.props;
        const { getFieldDecorator } = this.props.form;
        let self = this;
        message.config({
            duration: 10,
        });

        let createAnAerohiveCloudAccountHtml=  <div className="cloud-message-div-aerohiveCloudCtl"> 
            <div className="cloud-message-item-div-aerohiveCloudCtl" style={{marginTop:"24px"}}> 
                {self.state.i18n.cloudMessage1}
            </div>
            <div className="cloud-message-item-div-aerohiveCloudCtl"> 
                <strong>
                {self.state.i18n.cloudMessage2}
                </strong>
            </div>
            <div className="cloud-message-item-div-aerohiveCloudCtl"> 
                {self.state.i18n.cloudMessage3}
            </div>
            <div className="cloud-message-item-div-aerohiveCloudCtl"> 
                {self.state.i18n.cloudMessage4}
            </div>
            <div className="clear-float-div-common" ></div >
        </div>



        return (
            <div className="global-div-aerohiveCloudCtl">
            <Spin spinning={loading}>
                <div className="left-div-aerohiveCloudCtl">
                    <div className="guidance-div-aerohiveCloudCtl">
                        <div className="guidance-title-div-aerohiveCloudCtl">
                            {self.state.i18n.aerohiveCloud}
                        </div>
                        <div className="guidance-content-div-aerohiveCloudCtl">
                            {self.state.i18n.alreadyHasAnAerohiveCloudAccount1}<strong>{self.state.i18n.alreadyHasAnAerohiveCloudAccount2}</strong>{self.state.i18n.alreadyHasAnAerohiveCloudAccount3} 
                        </div>
                        <div className="guidance-content-div-aerohiveCloudCtl">
                            {self.state.i18n.firstExposureToAerohive1}<strong>{self.state.i18n.firstExposureToAerohive2}</strong>{self.state.i18n.firstExposureToAerohive3}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>
                    <div className="img-div-aerohiveCloudCtl">
                       <img src={aerohiveCloudImg} className="img-img-aerohiveCloudCtl" />
                    </div>
                    <div className="clear-float-div-common" ></div >
                </div>

                <div className="right-div-aerohiveCloudCtl">
                    
                    <Form onSubmit={self.handleSubmit.bind(self)}>

                    <div className="form-item-div-aerohiveCloudCtl">
                        <div className="form-item-title-div-aerohiveCloudCtl">
                            {self.state.i18n.cloudUrl}
                        </div>
                        <div className="form-item-input-div-aerohiveCloudCtl">
                            {getFieldDecorator('url', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckUrl.bind(self)}
                                maxLength={254}
                                placeholder="https://cloud.aerohive.com"
                                
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
                            {self.state.i18n.cloudAdminUser}
                        </div>
                        <div className="form-item-input-div-aerohiveCloudCtl">
                            {getFieldDecorator('user', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckUser.bind(self)}
                                maxLength={254}
                                placeholder="admin@example.com"
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
                            {self.state.i18n.password}
                        </div>
                        <div className="form-item-input-div-aerohiveCloudCtl">
                            {getFieldDecorator('pass', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckPass.bind(self)}
                                maxLength={254}
                                type={"password"}
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
                            >{self.state.i18n.linkWithAerohiveCloudAccount}</Button>
                        </div>
                    </div>
                    <div className="form-button-div-aerohiveCloudCtl">
                        <div className="form-button-create-div-aerohiveCloudCtl">
                            <Popover content={createAnAerohiveCloudAccountHtml} placement="rightBottom" title="" trigger="hover"
                            
                            >
                            <Button 
                                className="form-button-create-antd-button-aerohiveCloudCtl" 
                                onClick={self.onClickCreateAnAerohiveCloudAccount.bind(self)}
                                
                            >{self.state.i18n.createAnAerohiveCloudAccount}</Button>
                            </Popover>
                        </div>
                    </div>
                    <div className="form-button-continue-div-aerohiveCloudCtl"
                        onClick={self.onClickContinueWithoutAnAerohiveCloudAccount.bind(self)}
                    >
                        {self.state.i18n.continueWithoutAnAerohiveCloudAccount}
                    </div>



                    </Form>


              
                    <div className="clear-float-div-common" ></div >
                </div>

                <div className="clear-float-div-common" ></div >
            </Spin>
            </div>
            
        )
    }
}


export default Form.create()(aerohiveCloudCtl);



