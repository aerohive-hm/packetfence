import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio  ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail} from "../../libs/util";     
import '../../css/ctlComponents/licensingCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/licensingCtl";
import {i18n} from "../../i18n/ctlComponents/nls/licensingCtl";

import licensingImg from "../../media/licensing.png";
import thirtyDayTrialImg from "../../media/thirtyDayTrial.png";
import enterEntitlementKeyImg from "../../media/enterEntitlementKey.png";



const {Component} = React;

class licensingCtl extends Component {
    constructor(props) {
        super(props);
        this.state = {
            i18n:{},
            wrongMessage:{
                keyWrongMessage:"",
            },
            enterEntitlementKeyVisible:false,
            endUserLicenseAgreementVisible:false,
            enableEndUserLicenseAgreement:false,
        };


    }
    

    componentDidMount() {
        let self=this;
        self.getRightI18n();
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
            newWrongMessage.keyWrongMessage="Entitlement key is required.";
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

                self.setState({ 
                    key:values.key,
                    enterEntitlementKeyVisible:false,
                    endUserLicenseAgreementVisible:true,
                });
                


            }
        });
        
    }

    onCancelEnterEntitlementKey= () => {
        let self=this;
        self.setState({ 
            enterEntitlementKeyVisible:false,
        });

    }

    onCancelEndUserLicenseAgreementVisible= () => {
        let self=this;
        self.setState({ 
            endUserLicenseAgreementVisible:false,
        });

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
                        title={"Licensing"} 
                        content={"awgwaegWEE EEEEEEEEEE EEEEEEWfeWEFABERBAR WRBRAEBAERBBEABAWRBAERBAER BAEBABRAEBVAWRVAERBAERBAERBAERBAER BawgwaegWEEEE EEEEEEEEEEEEEEWfeWEFABERBA RWRBRAEBAERBBEABAWRBAE RBAERBAEB ABRAEBVAWR  VAERBAERBA ERBAERBAER BawgwaegWE EEEEEEEEEEE EEEEEEWfeWE FABERBARWRB RAEBAERBBEA BAWRBAER BAERBAEBAB RAEBVAWRVAERB AERBAERBAERBAERB ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"} 
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
                            30-DAY
                        </div>
                        <div className="thirty-day-trial-text-div-licensingCtl">
                            TRIAL
                        </div>
                        <div className="thirty-day-trial-button-div-licensingCtl">
                            START A 30-DAY TRIAL PERIOD
                        </div>
                
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="enter-entitlement-key-div-licensingCtl">
                        <div className="enter-entitlement-key-img-div-licensingCtl">
                            <img src={enterEntitlementKeyImg} className="enter-entitlement-key-img-img-licensingCtl" />
                        </div>
                        <div className="enter-entitlement-key-text-div-licensingCtl">
                            ENTER
                        </div>
                        <div className="enter-entitlement-key-text-div-licensingCtl">
                            ENTITLEMENT KEY
                        </div>
                        <div 
                            className="enter-entitlement-key-button-div-licensingCtl"
                            onClick={self.onClickEnterAnEntitlementKey.bind(self)}
                        >
                            ENTER AN ENTITLEMENT KEY
                        </div>
                
                        <div className="clear-float-div-common" ></div >
                    </div>

              
                    <div className="clear-float-div-common" ></div >
                </div>



                <Modal 
                    title="Enter Entitlement Key"
                    visible={enterEntitlementKeyVisible}
                    width={513}
                    footer={null}
                    onCancel={self.onCancelEnterEntitlementKey.bind(self)}
                >
         
                    <div className="modal-div-licensingCtl">
                        
                        <Form onSubmit={self.handleSubmit.bind(self)}>
                        <div className="modal-form-item-div-licensingCtl" style={{marginTop:"0px"}}>
                            <div className="modal-form-item-title-div-licensingCtl">
                                key:
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
                                >SUBMIT</Button>
                            </div>
                            <div className="modal-form-button-cancel-div-licensingCtl">
                                <Button 
                                    className="modal-form-button-cancel-antd-button-licensingCtl" 
                                    onClick={self.onCancelEnterEntitlementKey.bind(self)}
                                >CANCEL</Button>
                            </div>
                        </div>
                        </Form>


                
                        <div className="clear-float-div-common" ></div >
                    </div>
            
                </Modal>


                <Modal 
                    title="End User License Agreement"
                    visible={endUserLicenseAgreementVisible}
                    width={513}
                    footer={null}
                    onCancel={self.onCancelEndUserLicenseAgreementVisible.bind(self)}
                    closable={false}
                    maskClosable={false}
                    bodyStyle={{padding:"0px"}}
                >
         
                    <div className="modal-div-licensingCtl">
                        <div className="modal-eula-text-div-licensingCtl">
                            wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwafqafq sfvwevqeb   svqevqevqevewrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwafqafq sfvwevqeb   svqevqevqevewrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwafqafq sfvwevqeb   svqevqevqevewrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwafqafq sfvwevqeb   svqevqevqevewrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwafqafq sfvwevqeb   svqevqevqevewrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwafqafq sfvwevqeb   svqevqevqevewrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwafqafq sfvwevqeb   svqevqevqevewrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwww wrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwwrgweewwwwwwwwwwwwwwwwwwafqafq sfvwevqeb   svqevqevqeve
                        </div>
                        <div className="modal-eula-button-div-licensingCtl">
                            <div className="modal-eula-checkbox-div-licensingCtl">
                                <Checkbox 
                                    value={enableEndUserLicenseAgreement}
                                    onChange={self.onChangeCheckbox.bind(self)}
                                ></Checkbox>
                            </div>
                            <div className="modal-eula-checkbox-text-div-licensingCtl">
                                I agree to these terms
                            </div>
                            <div className="modal-eula-submit-div-licensingCtl">
                                <Button 
                                    disabled={enableEndUserLicenseAgreement===true?false:true}
                                    type="primary" 
                                    className="modal-eula-submit-antd-button-licensingCtl" 
                                    onClick={self.onCancelEndUserLicenseAgreementVisible.bind(self)}
                                >CANCEL</Button>
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



