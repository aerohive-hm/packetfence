import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio  ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail,isEntitlementkey} from "../../libs/util";     
import '../../css/ctlComponents/licensingCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/licensingCtl";
import {i18n} from "../../i18n/ctlComponents/nls/licensingCtl";

import licensingImg from "../../media/licensing.svg";
import thirtyDayTrialImg from "../../media/thirtyDayTrial.svg";
import enterEntitlementKeyImg from "../../media/enterEntitlementKey.svg";



const {Component} = React;

class licensingCtl extends Component {
    constructor(props) {
        super(props);
        this.state = {
            i18n:{},
            wrongMessage:{
                keyWrongMessage:"",
            },
            key:"",
            enterEntitlementKeyVisible:false,
            endUserLicenseAgreementVisible:false,
            enableEndUserLicenseAgreement:false,
        };


    }
    

    componentDidMount() {
        let self=this;
        self.getRightI18n();
        if(self.props.show==="licensing,enterEntitlementKey"){
            self.setState({
                enterEntitlementKeyVisible:true,
            });
        }
        if(self.props.show==="licensing,endUserLicenseAgreement"){
            self.setState({
                endUserLicenseAgreementVisible:true,
            });
        }

    }


    onChangeCheckbox=(e)=>{
        let self=this;
        this.setState({
            enableEndUserLicenseAgreement: e.target.checked,
        });
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

    onBlurCheckKey(e){
        let self=this;
        self.checkKey(e.target.value);
    }

    checkKey=(key)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!key||key.toString().trim()===""){
            newWrongMessage.keyWrongMessage=self.state.i18n.entitlementKeyIsRequired;
        }else
        if(isEntitlementkey(key.toString().trim())===false){
            newWrongMessage.keyWrongMessage=self.state.i18n.entitlementKeyFormatIsIncorrect;
        }else{    
            newWrongMessage.keyWrongMessage="";
        }


        self.setState({
            wrongMessage:newWrongMessage
        })
        if(newWrongMessage.keyWrongMessage===""){
            $("#key").css({
                "border":"1px solid #d9d9d9",
            });
            return true;
        }else{
            $("#key").css({
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
                if(self.checkKey(values.key)===false){
                    hasWrongValue=true;
                    $("#key").focus();
                }
                if(hasWrongValue===true){
                    return;
                }


                let xCsrfToken="";
                let url= "/a3/api/v1/configurator/license";
                
                let param={
                    trial:"0",
                    key:values.key,
                }

                new RequestApi('post',url,JSON.stringify(param),xCsrfToken,(data)=>{
                    if(data.code==="ok"){
                        self.setState({ 
                            key:values.key,
                            enterEntitlementKeyVisible:false,
                            endUserLicenseAgreementVisible:true,
                        });
                    }else{
                        message.destroy();
                        message.error(data.msg);
                    }

                }) 


                


            }
        });
        
    }

    onCancelEnterEntitlementKey= () => {
        let self=this;
        self.setState({ 
            enterEntitlementKeyVisible:false,
        });

    }

    onSubmitEndUserLicenseAgreementVisible= () => {
        let self=this;

        let xCsrfToken="";
        let url= "/a3/api/v1/configurator/license";
        
        let param={
            trial:"0",
            eula_accept:true,
            key:self.state.key,
        }

        new RequestApi('post',url,JSON.stringify(param),xCsrfToken,(data)=>{
            if(data.code==="ok"){
                self.setState({ 
                    endUserLicenseAgreementVisible:false,
                });
                self.props.changeStatus("aerohiveCloud");
            }else{
                message.destroy();
                message.error(data.msg);
            }

        }) 

    }

    onClickStartThirtyDaysTrial= () => {
        let self=this;

        let xCsrfToken="";
        let url= "/a3/api/v1/configurator/license";
        
        let param={
            trial:"1",
        }

        new RequestApi('post',url,JSON.stringify(param),xCsrfToken,(data)=>{
            if(data.code==="ok"){
                self.props.changeStatus("aerohiveCloud");
            }else{
                message.destroy();
                message.error(data.msg);
            }

        }) 

    }

    onClickEnterAnEntitlementKey= () => {
        let self=this;
        self.props.form.setFieldsValue({
            key:"",
        })
        $("#key").css({
            "border":"1px solid #d9d9d9",
        });
        let wrongMessageCopy=self.state.wrongMessage;
        wrongMessageCopy.keyWrongMessage="";
        self.setState({ 
            enterEntitlementKeyVisible:true,
        });
    }





    render() {
        const {wrongMessage,enterEntitlementKeyVisible,endUserLicenseAgreementVisible,enableEndUserLicenseAgreement} = this.state;
        const {} = this.props;
        const { getFieldDecorator } = this.props.form;
        let self = this;
        message.config({
            duration: 10,
        });
        return (
            <div className="global-div-licensingCtl">
                <div className="left-div-licensingCtl">
                    <Guidance 
                        title={self.state.i18n.licensing} 
                        content={[self.state.i18n.licensingMessage1,self.state.i18n.licensingMessage2]} 
                    />
                    <div className="img-div-licensingCtl">
                       <img src={licensingImg} className="img-img-licensingCtl" />
                    </div>
                    <div className="clear-float-div-common" ></div >
                </div>

                <div className="right-div-licensingCtl">
                    <div className="thirty-day-trial-div-licensingCtl">
                        <div className="thirty-day-trial-img-div-licensingCtl">
                            <img src={thirtyDayTrialImg} className="thirty-day-trial-img-img-licensingCtl" />
                        </div>
                        <div className="thirty-day-trial-text-div-licensingCtl">
                            {self.state.i18n.thirtyDay}
                        </div>
                        <div className="thirty-day-trial-text-div-licensingCtl">
                            {self.state.i18n.trial}
                        </div>
                        <div className="thirty-day-trial-button-div-licensingCtl"
                            onClick={self.onClickStartThirtyDaysTrial.bind(self)}
                        >
                            {self.state.i18n.startAThirtyDayTrialPeriod}
                        </div>
                
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="enter-entitlement-key-div-licensingCtl">
                        <div className="enter-entitlement-key-img-div-licensingCtl">
                            <img src={enterEntitlementKeyImg} className="enter-entitlement-key-img-img-licensingCtl" />
                        </div>
                        <div className="enter-entitlement-key-text-div-licensingCtl">
                            {self.state.i18n.enter}
                        </div>
                        <div className="enter-entitlement-key-text-div-licensingCtl">
                            {self.state.i18n.entitlementKey}
                        </div>
                        <div 
                            className="enter-entitlement-key-button-div-licensingCtl"
                            onClick={self.onClickEnterAnEntitlementKey.bind(self)}
                        >
                            {self.state.i18n.enterAnEntitlementKey}
                        </div>
                
                        <div className="clear-float-div-common" ></div >
                    </div>

              
                    <div className="clear-float-div-common" ></div >
                </div>



                <Modal 
                    title={self.state.i18n.enterEntitlementKey}
                    visible={enterEntitlementKeyVisible}
                    width={513}
                    footer={null}
                    onCancel={self.onCancelEnterEntitlementKey.bind(self)}
                    closable={false}
                    maskClosable={false}
                >
         
                    <div className="modal-div-licensingCtl">
                        
                        <Form onSubmit={self.handleSubmit.bind(self)}>
                        <div className="modal-form-item-div-licensingCtl" style={{marginTop:"0px"}}>
                            <div className="modal-form-item-title-div-licensingCtl">
                                {self.state.i18n.key}
                            </div>
                            <div className="modal-form-item-input-div-licensingCtl">
                                {getFieldDecorator('key', {
                                    rules: [],
                                })(
                                    <Input 
                                    style={{height:"32px"}}
                                    onBlur={self.onBlurCheckKey.bind(self)}
                                    />
                                )}
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>
                        <div className="modal-form-item-wrong-div-licensingCtl" 
                        style={{color:wrongMessage.keyWrongMessage===""?"#ffffff":"#f44336"}}>
                                {wrongMessage.keyWrongMessage}
                        </div>

                        <div className="modal-form-button-div-licensingCtl">
                            <div className="modal-form-button-next-div-licensingCtl">
                                <Button 
                                    type="primary" 
                                    className="modal-form-button-next-antd-button-licensingCtl" 
                                    htmlType="submit" 
                                >{self.state.i18n.submit}</Button>
                            </div>
                            <div className="modal-form-button-cancel-div-licensingCtl">
                                <Button 
                                    className="modal-form-button-cancel-antd-button-licensingCtl" 
                                    onClick={self.onCancelEnterEntitlementKey.bind(self)}
                                >{self.state.i18n.cancel}</Button>
                            </div>
                        </div>
                        </Form>


                
                        <div className="clear-float-div-common" ></div >
                    </div>
            
                </Modal>


                <Modal 
                    title={self.state.i18n.endUserLicenseAgreement}
                    visible={endUserLicenseAgreementVisible}
                    width={513}
                    footer={null}
                    closable={false}
                    maskClosable={false}
                    bodyStyle={{padding:"0px"}}
                >
         
                    <div className="modal-div-licensingCtl">
                        <div className="modal-eula-text-div-licensingCtl">
                            <div className="modal-eula-margin-top-0-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem1}
                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem2}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem3}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem4}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem5}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem6}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem7}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem8}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem9}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem10}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem11}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem12}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem13}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem14}

                            </div>
                            <div className="modal-eula-margin-top-0-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem15}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem16}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem17}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem18}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem19}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem20}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem21}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem22}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem23}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem24}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem25}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem26}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem27} 

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem28}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem29}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem30}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem31}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem32}

                            </div>
                            <div className="modal-eula-margin-top-0-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem33}

                            </div>
                            <div className="modal-eula-margin-top-0-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem34}

                            </div>
                            <div className="modal-eula-margin-top-0-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem35}

                            </div>
                            <div className="modal-eula-margin-top-0-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem36}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem37}

                            </div>
                            <div className="modal-eula-margin-top-16-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem38}

                            </div>
                            <div className="modal-eula-margin-top-0-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem39}

                            </div>
                            <div className="modal-eula-margin-top-0-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem40}

                            </div>
                            <div className="modal-eula-margin-top-0-text-div-licensingCtl">
                                {self.state.i18n.endUserLicenseAgreementItem41}

                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>
                        <div className="modal-eula-button-div-licensingCtl">
                            <div className="modal-eula-checkbox-div-licensingCtl">
                                <Checkbox 
                                    value={enableEndUserLicenseAgreement}
                                    onChange={self.onChangeCheckbox.bind(self)}
                                ></Checkbox>
                            </div>
                            <div className="modal-eula-checkbox-text-div-licensingCtl">
                                {self.state.i18n.agreeToTheseTerms}
                            </div>
                            <div className="modal-eula-submit-div-licensingCtl">
                                <Button 
                                    disabled={enableEndUserLicenseAgreement===true?false:true}
                                    type="primary" 
                                    className="modal-eula-submit-antd-button-licensingCtl" 
                                    onClick={self.onSubmitEndUserLicenseAgreementVisible.bind(self)}
                                >{self.state.i18n.submit}</Button>
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>
                </Modal>

                <div className="clear-float-div-common" ></div >
            </div>
            
        )
    }
}


export default Form.create()(licensingCtl);



