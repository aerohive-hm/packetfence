import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio  ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail,isIp,isUrl} from "../../libs/util";     
import '../../css/ctlComponents/joinClusterCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/joinClusterCtl";
import {i18n} from "../../i18n/ctlComponents/nls/joinClusterCtl";

import joinClusterImg from "../../media/joinCluster.svg";



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

    onClickCancel = () => {
        let self=this;
        self.props.form.resetFields();
        self.props.changeStatus("getStart");
        
    }
    onBlurCheckPrimaryServer(e){
        let self=this;
        self.checkPrimaryServer(e.target.value);
    }

    checkPrimaryServer=(primaryServer)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!primaryServer||primaryServer.toString().trim()===""){
            newWrongMessage.primaryServerWrongMessage=self.state.i18n.clusterPrimaryIsRequired;
        }else
        // if(isUrl(primaryServer.toString().trim())===false){
        //     newWrongMessage.primaryServerWrongMessage=self.state.i18n.clusterPrimaryMustStartWith;
        // }else
        {
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
            newWrongMessage.adminWrongMessage=self.state.i18n.clusterAdminIsRequired;
        }else
        if(isEmail(admin.toString().trim())===false){
            newWrongMessage.adminWrongMessage=self.state.i18n.emailFormatIsIncorrect;
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
            newWrongMessage.passwdWrongMessage=self.state.i18n.adminPasswordIsRequired;
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



                let xCsrfToken="";
                let url= "/a3/api/v1/configurator/cluster/join";
                
                let param={
                    "primary_server":values.primary_server.toString().trim(),
                    "admin":values.admin.toString().trim(),
                    "passwd":values.passwd,

                }
                self.setState({
                    loading : true,
                })
                new RequestApi('post',url,JSON.stringify(param),xCsrfToken,(data)=>{
                    if(data.code==="ok"){
                        self.setState({
                            loading : false,
                        },function(){
                            self.props.changeStatus("clusterNetworking");
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



    render() {
        const {wrongMessage,loading} = this.state;
        const {} = this.props;
        const { getFieldDecorator } = this.props.form;
        let self = this;
        message.config({
            duration: 10,
        });
        return (
            <div className="global-div-joinClusterCtl">
            <Spin spinning={loading}>
                <div className="left-div-joinClusterCtl">
                    <Guidance 
                        title={self.state.i18n.joinCluster} 
                        content={[self.state.i18n.joinClusterMessage]} 
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
                            {self.state.i18n.clusterPrimary}
                        </div>
                        <div className="form-item-input-div-joinClusterCtl">
                            {getFieldDecorator('primary_server', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckPrimaryServer.bind(self)}
                                maxLength={254}
                                
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
                            {self.state.i18n.clusterAdmin}
                        </div>
                        <div className="form-item-input-div-joinClusterCtl">
                            {getFieldDecorator('admin', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckAdmin.bind(self)}
                                maxLength={254}
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
                            {self.state.i18n.adminPassword}
                        </div>
                        <div className="form-item-input-div-joinClusterCtl">
                            {getFieldDecorator('passwd', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckPasswd.bind(self)}
                                maxLength={254}
                                type={"password"}
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
                            >{self.state.i18n.next}</Button>
                        </div>
                        <div className="form-button-cancel-div-joinClusterCtl">
                            <Button 
                                className="form-button-cancel-antd-button-joinClusterCtl" 
                                onClick={self.onClickCancel.bind(self)}
                            >{self.state.i18n.cancel}</Button>
                        </div>
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


export default Form.create()(joinClusterCtl);



