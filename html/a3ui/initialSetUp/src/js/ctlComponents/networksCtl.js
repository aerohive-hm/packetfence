import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio  ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail,isIp,isPositiveInteger,isHostname,isVlan} from "../../libs/util";     
import '../../css/ctlComponents/networksCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/networksCtl";
import {i18n} from "../../i18n/ctlComponents/nls/networksCtl";

import networksImg from "../../media/networks.svg";

import editNoImg from "../../media/editNo.svg";
import editYesImg from "../../media/editYes.svg";
import addVlanImg from "../../media/addVlan.svg";
import removeVlanImg from "../../media/removeVlan.svg";

const {Component} = React;

class networksCtl extends Component {
    constructor(props) {
        super(props);
        this.state = {
            i18n:{},
            wrongMessage:{
                hostnameWrongMessage:"",
                nameWrongMessage:"",
                ipAddrWrongMessage:"",
                netmaskWrongMessage:"",
                vipWrongMessage:"",
            },
            enableClustering:true,
            loading:false,
            dataTable:[],
            isEditing:false,
            originalDescription:"",
            addVlanVisible:false,
        };


    }
    

    componentDidMount() {
        let self=this;
        self.getRightI18n();
        self.getData();
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

    getData= () => {
        let self=this;

        let xCsrfToken="";
        let url= "/a3/api/v1/configurator/networks";
         
        let param={
        }
        
        self.setState({
            loading : true,
        })

        new RequestApi('get',url,param,xCsrfToken,(data)=>{
            self.getTrueData(data);
        },()=>{
            self.setState({
                loading : false,
            })

        });

        //self.getTrueData(mock.networks);
    }

    getTrueData= (data) => {
        let self=this;
        let dataTable=data.items;
        for(let i=0;i<dataTable.length;i++){
            dataTable[i].key=dataTable[i].name;
            dataTable[i].vlan=dataTable[i].name;
            dataTable[i].clicked="";
            dataTable[i].services=dataTable[i].services===""?[]:dataTable[i].services.split(",");
        }
        self.setState({
            enableClustering:data.cluster_enable,
            dataTable: dataTable,
            loading : false,
        }); 
        self.props.form.resetFields();
        self.props.form.setFieldsValue({
            hostname:data.hostname,
        });
    }

    getDataTable= () => {
        let self=this;

        let xCsrfToken="";
        let url= "/a3/api/v1/configurator/networks";
         
        let param={
        }
        
        self.setState({
            loading : true,
        })

        new RequestApi('get',url,param,xCsrfToken,(data)=>{
            self.getTrueDataTable(data);
        },()=>{
            self.setState({
                loading : false,
            })

        });

        //self.getTrueData(mock.networks);
    }

    getTrueDataTable= (data) => {
        let self=this;
        let dataTable=data.items;
        for(let i=0;i<dataTable.length;i++){
            dataTable[i].key=dataTable[i].name;
            dataTable[i].vlan=dataTable[i].name;
            dataTable[i].clicked="";
            dataTable[i].services=dataTable[i].services===""?[]:dataTable[i].services.split(",");
        }
        self.setState({
            dataTable: dataTable,
            loading : false,
        }); 
    }


    onChangeCheckbox=(e)=>{
        let self=this;
        if(self.state.isEditing===true){
            message.destroy();
            message.error(self.state.i18n.pleaseFinishTheEditFirst);
            return;
        }

        let xCsrfToken="";
        let url= "/a3/api/v1/configurator/networks";
        
        let param={
            cluster_enable:e.target.checked,
        }

        self.setState({
            loading : true,
        })

        new RequestApi('post',url,JSON.stringify(param),xCsrfToken,(data)=>{
            if(data.code==="ok"){
                self.setState({
                    loading : false,
                    enableClustering: e.target.checked,
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

    onBlurCheckHostname(e){
        let self=this;
        self.checkHostname(e.target.value);
    }

    checkHostname=(hostname)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!hostname||hostname.toString().trim()===""){
            newWrongMessage.hostnameWrongMessage=self.state.i18n.hostNameIsRequired;
        }else
        if(isHostname(hostname.toString().trim())===false){
            newWrongMessage.hostnameWrongMessage=self.state.i18n.invalidHostName;
        }else{
            newWrongMessage.hostnameWrongMessage="";
        }


        self.setState({
            wrongMessage:newWrongMessage
        })
        if(newWrongMessage.hostnameWrongMessage===""){
            $("#hostname").css({
                "border":"1px solid #d9d9d9",
            });
            return true;
        }else{
            $("#hostname").css({
                "border":"1px solid red",
            });
            
            return false;
        }
    }



    onBlurCheckName(e){
        let self=this;
        self.checkName(e.target.value);
    }

    checkName=(name,type)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!name||name.toString().trim()===""){
            newWrongMessage.nameWrongMessage=self.state.i18n.nameIsRequired;
        }else
        if(isVlan(name.toString().trim())===false){
            newWrongMessage.nameWrongMessage=self.state.i18n.nameMustBeBetween;
        }else{
            newWrongMessage.nameWrongMessage="";
        }

        if(type==="table"){
            if(newWrongMessage.nameWrongMessage!==""){
                message.destroy();
                message.error(newWrongMessage.nameWrongMessage);
                newWrongMessage.nameWrongMessage="";
                return false;
            }else{
                return true;
            }

        }else{
            self.setState({
                wrongMessage:newWrongMessage
            })
            if(newWrongMessage.nameWrongMessage===""){
                $("#name").css({
                    "border":"1px solid #d9d9d9",
                });
                return true;
            }else{
                $("#name").css({
                    "border":"1px solid red",
                });
                
                return false;
            }
        }



    }

    onBlurCheckIpAddr(e){
        let self=this;
        self.checkIpAddr(e.target.value);
    }

    checkIpAddr=(ipAddr,type)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!ipAddr||ipAddr.toString().trim()===""){
            newWrongMessage.ipAddrWrongMessage=self.state.i18n.iPAddressIsRequired;
        }else
        if(isIp(ipAddr.toString().trim())===false){
            newWrongMessage.ipAddrWrongMessage=self.state.i18n.iPAddressFormatIsIncorrect;
        }else{
            newWrongMessage.ipAddrWrongMessage="";
        }

        if(type==="table"){
            if(newWrongMessage.ipAddrWrongMessage!==""){
                message.destroy();
                message.error(newWrongMessage.ipAddrWrongMessage);
                newWrongMessage.ipAddrWrongMessage="";
                return false;
            }else{
                return true;
            }

        }else{
            self.setState({
                wrongMessage:newWrongMessage
            })
            if(newWrongMessage.ipAddrWrongMessage===""){
                $("#ip_addr").css({
                    "border":"1px solid #d9d9d9",
                });
                return true;
            }else{
                $("#ip_addr").css({
                    "border":"1px solid red",
                });
                
                return false;
            }
        }
    }

    onBlurCheckNetmask(e){
        let self=this;
        self.checkNetmask(e.target.value);
    }

    checkNetmask=(netmask,type)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!netmask||netmask.toString().trim()===""){
            newWrongMessage.netmaskWrongMessage=self.state.i18n.netmaskIsRequired;
        }else
        if(isIp(netmask.toString().trim())===false){
            newWrongMessage.netmaskWrongMessage=self.state.i18n.netmaskFormatIsIncorrect;
        }else{
            newWrongMessage.netmaskWrongMessage="";
        }

        if(type==="table"){
            if(newWrongMessage.netmaskWrongMessage!==""){
                message.destroy();
                message.error(newWrongMessage.netmaskWrongMessage);
                newWrongMessage.netmaskWrongMessage="";
                return false;
            }else{
                return true;
            }

        }else{
            self.setState({
                wrongMessage:newWrongMessage
            })
            if(newWrongMessage.netmaskWrongMessage===""){
                $("#netmask").css({
                    "border":"1px solid #d9d9d9",
                });
                return true;
            }else{
                $("#netmask").css({
                    "border":"1px solid red",
                });
                
                return false;
            }
        }
    }


    onBlurCheckVip(e){
        let self=this;
        self.checkVip(e.target.value);
    }

    checkVip=(vip,type)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!vip||vip.toString().trim()===""){
            newWrongMessage.vipWrongMessage=self.state.i18n.vipIsRequired;
        }else
        if(isIp(vip.toString().trim())===false){
            newWrongMessage.vipWrongMessage=self.state.i18n.vipFormatIsIncorrect;
        }else{
            newWrongMessage.vipWrongMessage="";
        }

        if(type==="table"){
            if(newWrongMessage.vipWrongMessage!==""){
                message.destroy();
                message.error(newWrongMessage.vipWrongMessage);
                newWrongMessage.vipWrongMessage="";
                return false;
            }else{
                return true;
            }

        }else{
            self.setState({
                wrongMessage:newWrongMessage
            })
            if(newWrongMessage.vipWrongMessage===""){
                $("#vip").css({
                    "border":"1px solid #d9d9d9",
                });
                return true;
            }else{
                $("#vip").css({
                    "border":"1px solid red",
                });
                
                return false;
            }
        }
    }

    getItems= () => {
        let self=this;
        let items=[];
        for(let i=0;i<self.state.dataTable.length;i++){
            items.push({
                name:self.state.dataTable[i].name,
                ip_addr:self.state.dataTable[i].ip_addr,
                netmask:self.state.dataTable[i].netmask,
                vip:self.state.dataTable[i].vip,
                type:self.state.dataTable[i].type,
                services:self.state.dataTable[i].services.join(","),
            });
        }
        return items;
    }

    handleSubmit = (e) => {
        let self=this;
        e.preventDefault();
        if(self.state.isEditing===true){
            message.destroy();
            message.error(self.state.i18n.pleaseFinishTheEditFirst);
            return;
        }
        this.props.form.validateFields((err, values) => {
            if (!err) {
                console.log(values);
                let hasWrongValue=false;
                if(self.checkHostname(values.hostname)===false){
                    hasWrongValue=true;
                    $("#hostname").focus();
                }
                if(hasWrongValue===true){
                    return;
                }

                let xCsrfToken="";
                let url= "/a3/api/v1/configurator/networks";
                
                let param={
                    cluster_enable:self.state.enableClustering,
                    hostname:values.hostname.trim(),
                    items:self.getItems(),
                }

                self.setState({
                    loading : true,
                })

                new RequestApi('post',url,JSON.stringify(param),xCsrfToken,(data)=>{
                    if(data.code==="ok"){
                        self.setState({
                            loading : false,
                        },function(){
                            self.props.changeStatus("licensing");
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

    onClickCancel = () => {
        let self=this;
        self.props.form.resetFields();
        
    }

    onClickText= (index,column) => {
        let self=this;
        
        if(self.state.isEditing===true){
            message.destroy();
            message.error(self.state.i18n.pleaseFinishTheEditFirst);
            return;
        }

        let dataCopy=self.state.dataTable;
        dataCopy[index].clicked=column;
        self.setState({
            dataTable : dataCopy,
            originalDescription:dataCopy[index][column],
            isEditing:true,
        });
    }

    onEdit=(index,column,e) =>{
        let self=this;
        let dataCopy=self.state.dataTable;
        if(column==="name"){
            dataCopy[index][column]="VLAN"+e.target.value.toString().trim();
        }else{
            dataCopy[index][column]=e.target.value;
        }
        
        self.setState({ 
            dataTable : dataCopy, 
        });

    }

    onChangeSelect=(index,column,value) =>{
        let self=this;
        if(self.state.isEditing===true){
            message.destroy();
            message.error(self.state.i18n.pleaseFinishTheEditFirst);
            return;
        }
        let xCsrfToken="";
        let url= "/a3/api/v1/configurator/interface";

        let dataCopy=self.state.dataTable;
        
        let param
        if(column==="type"){
            param={
                "original":dataCopy[index].original,
                "name":dataCopy[index].name.trim(),
                "ip_addr":dataCopy[index].ip_addr.trim(),
                "netmask":dataCopy[index].netmask.trim(),
                "vip":dataCopy[index].vip.trim(),
                "type":value,
                "services":dataCopy[index].services.join(","),
            }
        }else{
            param={
                "original":dataCopy[index].original,
                "name":dataCopy[index].name.trim(),
                "ip_addr":dataCopy[index].ip_addr.trim(),
                "netmask":dataCopy[index].netmask.trim(),
                "vip":dataCopy[index].vip.trim(),
                "type":dataCopy[index].type,
                "services":value.join(","),
            } 
        }
        self.setState({
            loading : true,
        })

        new RequestApi('post',url,JSON.stringify(param),xCsrfToken,(data)=>{
            if(data.code==="ok"){
                dataCopy[index][column]=value;
                self.setState({ 
                    dataTable : dataCopy, 
                    loading : false,
                });
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


    onClickEditOk= (index,column) => {
        let self=this;

        if(column==="name"&&self.checkName(self.state.dataTable[index].name.slice(4),"table")===false){
            return;
        }
        if(column==="ip_addr"&&self.checkIpAddr(self.state.dataTable[index].ip_addr,"table")===false){
            return;
        }
        if(column==="netmask"&&self.checkNetmask(self.state.dataTable[index].netmask,"table")===false){
            return;
        }
        if(column==="vip"&&self.checkVip(self.state.dataTable[index].vip,"table")===false){
            return;
        }


        let xCsrfToken="";
        let url= "/a3/api/v1/configurator/interface";

        let dataCopy=self.state.dataTable;
        
        let param={
            "original":dataCopy[index].original,
            "name":dataCopy[index].name.trim(),
            "ip_addr":dataCopy[index].ip_addr.trim(),
            "netmask":dataCopy[index].netmask.trim(),
            "vip":dataCopy[index].vip.trim(),
            "type":dataCopy[index].type,
            "services":dataCopy[index].services.join(","),
        }

        self.setState({
            loading : true,
        })

        new RequestApi('post',url,JSON.stringify(param),xCsrfToken,(data)=>{
            if(data.code==="ok"){
                dataCopy[index].clicked="";
                self.setState({
                    dataTable : dataCopy,
                    isEditing: false,
                    loading : false,
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

    onClickEditNo= (index,column) => {
        let self=this;

        let dataCopy=self.state.dataTable;
        dataCopy[index].clicked="";
        dataCopy[index][column]=self.state.originalDescription;
        self.setState({ 
            dataTable : dataCopy,
            isEditing:false,
        });
    }

    onClickAddVlan= (index) => {
        let self=this;
        if(self.state.isEditing===true){
            message.destroy();
            message.error(self.state.i18n.pleaseFinishTheEditFirst);
            return;
        }
        self.props.form.setFieldsValue({
            name:"",
            ip_addr:"",
            netmask:"",
            vip:"",
            type:"MANAGEMENT",
            services:["PORTAL"],

        })
        $("#name,#ip_addr,#netmask,#vip").css({
            "border":"1px solid #d9d9d9",
        });
        let wrongMessageCopy=self.state.wrongMessage;
        wrongMessageCopy.nameWrongMessage="";
        wrongMessageCopy.ipAddrWrongMessage="";
        wrongMessageCopy.netmaskWrongMessage="";
        wrongMessageCopy.vipWrongMessage="";
        self.setState({ 
            addVlanVisible:true,
        });

    }


    onOkAddVlan = (e) => {
        let self=this;
        e.preventDefault();
        this.props.form.validateFields((err, values) => {
            if (!err) {

                console.log(values);

                let hasWrongValue=false;

                if(self.state.enableClustering===true){
                    if(self.checkVip(values.vip)===false){
                        hasWrongValue=true;
                        $("#vip").focus();
                    }
                }

                if(self.checkNetmask(values.netmask)===false){
                    hasWrongValue=true;
                    $("#netmask").focus();
                }
                if(self.checkIpAddr(values.ip_addr)===false){
                    hasWrongValue=true;
                    $("#ip_addr").focus();
                }
                if(self.checkName(values.name)===false){
                    hasWrongValue=true;
                    $("#name").focus();
                }
                if(hasWrongValue===true){
                    return;
                }


                let xCsrfToken="";
                let url= "/a3/api/v1/configurator/interface";
                
                let param={
                    "original":"",
                    "name":"VLAN"+values.name.toString().trim(),
                    "ip_addr":values.ip_addr.trim(),
                    "netmask":values.netmask.trim(),
                    "vip":values.vip.trim(),
                    "type":values.type,
                    "services":values.services.join(","),
                }
                self.setState({
                    loading : true,
                })
                new RequestApi('put',url,JSON.stringify(param),xCsrfToken,(data)=>{
                    if(data.code==="ok"){
                        self.setState({ 
                            addVlanVisible:false,
                            loading : false,
                        },function(){
                            self.getDataTable();
                        });
                        
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


    onCancelAddVlan= () => {
        let self=this;
        self.setState({ 
            addVlanVisible:false,
        });

    }

    onClickRemoveVlan= (index) => {
        let self=this;
        if(self.state.isEditing===true){
            message.destroy();
            message.error(self.state.i18n.pleaseFinishTheEditFirst);
            return;
        }
        Modal.confirm({
            content: self.state.i18n.areYouSureYouWantToDoThis,
            okText: self.state.i18n.yes,
            cancelText: self.state.i18n.no,
            onOk() {
                let dataCopy=self.state.dataTable;

                let xCsrfToken="";
                let url= "/a3/api/v1/configurator/interface";
                
                let param={
                    "original":dataCopy[index].original,
                    "name":dataCopy[index].name.trim(),
                    "ip_addr":dataCopy[index].ip_addr.trim(),
                    "netmask":dataCopy[index].netmask.trim(),
                    "vip":dataCopy[index].vip.trim(),
                    "type":dataCopy[index].type,
                    "services":dataCopy[index].services.join(","),
                }
                self.setState({
                    loading : true,
                })
                new RequestApi('delete',url,JSON.stringify(param),xCsrfToken,(data)=>{
                    if(data.code==="ok"){
                        dataCopy.splice(index,1);
                        self.setState({ 
                            dataTable : dataCopy,
                            loading : false,
                        });
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

            },
            onCancel() {},
        });

    }


    render() {
        const {wrongMessage,enableClustering,dataTable,loading,addVlanVisible} = this.state;
        const {} = this.props;
        const { getFieldDecorator } = this.props.form;
        let self = this;
        message.config({
            duration: 10,
        });

        let columns=[];
        columns.push({
            title:self.state.i18n.name,
            dataIndex: 'name',
            key: 'name',
            width:'157px',
            render: (text, record, index) => {
                let numberHtml;
                if(dataTable[index].clicked==="name"){
                    numberHtml=
                        <div className="name-edit-div-networksCtl"  >
                            <div className="name-edit-input-div-networksCtl">
                                <Input
                                    value={text.slice(4)}
                                    autoFocus
                                    onChange={self.onEdit.bind(self,index,"name")}
                                />
                            </div>
                            <div className="name-edit-ok-div-networksCtl" onClick={self.onClickEditOk.bind(self,index,"name")}>
                                <img className="name-edit-ok-img-networksCtl" src={editYesImg} />
                            </div>
                            <div className="name-edit-no-div-networksCtl" onClick={self.onClickEditNo.bind(self,index,"name")}>
                                <img className="name-edit-no-img-networksCtl" src={editNoImg} />
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>
                }else{
                    numberHtml=
                        <div className="name-text-div-networksCtl" onClick={self.onClickText.bind(self,index,"name")} >
                            {text.slice(4)}
                        </div>
                }


                return (
                    text.indexOf("VLAN")===-1?
                    <div className="name-etho-div-networksCtl"  >
                        {text}
                    </div>
                    :
                    <div className="name-vlan-div-networksCtl">
                        <div className="name-vlan-blank-div-networksCtl">
                        </div>
                        <div className="name-vlan-text-div-networksCtl">
                            VLAN
                        </div>
                        {numberHtml}
                        <div className="clear-float-div-common" ></div >
                    </div>
                );
            } 
        });
        columns.push({
            title: self.state.i18n.iPAddress,
            dataIndex: 'ip_addr',
            key: 'ip_addr',
            width:'129px',
            render: (text, record, index) => {
                return (
                    <div>
                        {
                            dataTable[index].clicked==="ip_addr"?
                            <div className="ipAddr-edit-div-networksCtl"  >
                                <div className="ipAddr-edit-input-div-networksCtl">
                                    <Input
                                        value={text}
                                        autoFocus
                                        onChange={self.onEdit.bind(self,index,"ip_addr")}
                                    />
                                </div>
                                <div className="ipAddr-edit-ok-div-networksCtl" onClick={self.onClickEditOk.bind(self,index,"ip_addr")}>
                                    <img className="ipAddr-edit-ok-img-networksCtl" src={editYesImg} />
                                </div>
                                <div className="ipAddr-edit-no-div-networksCtl" onClick={self.onClickEditNo.bind(self,index,"ip_addr")}>
                                    <img className="ipAddr-edit-no-img-networksCtl" src={editNoImg} />
                                </div>
                                <div className="clear-float-div-common" ></div >
                            </div>
                            :
                            <div className="ipAddr-text-div-networksCtl" onClick={self.onClickText.bind(self,index,"ip_addr")} >
                                {text}
                            </div>
                        }
                    </div>
                );
            } 
        });
        columns.push({
            title:self.state.i18n.netmask,
            dataIndex: 'netmask',
            key: 'netmask',
            width:'129px',
            render: (text, record, index) => {
                return (
                    <div>
                        {
                            dataTable[index].clicked==="netmask"?
                            <div className="netmask-edit-div-networksCtl"  >
                                <div className="netmask-edit-input-div-networksCtl">
                                    <Input
                                        value={text}
                                        autoFocus
                                        onChange={self.onEdit.bind(self,index,"netmask")}
                                    />
                                </div>
                                <div className="netmask-edit-ok-div-networksCtl" onClick={self.onClickEditOk.bind(self,index,"netmask")}>
                                    <img className="netmask-edit-ok-img-networksCtl" src={editYesImg} />
                                </div>
                                <div className="netmask-edit-no-div-networksCtl" onClick={self.onClickEditNo.bind(self,index,"netmask")}>
                                    <img className="netmask-edit-no-img-networksCtl" src={editNoImg} />
                                </div>
                                <div className="clear-float-div-common" ></div >
                            </div>
                            :
                            <div className="netmask-text-div-networksCtl" onClick={self.onClickText.bind(self,index,"netmask")} >
                                {text}
                            </div>
                        }
                    </div>
                );
            } 
        });

        if(enableClustering===true){
            columns.push({
                title:self.state.i18n.vip,
                dataIndex: 'vip',
                key: 'vip',
                width:'129px',
                render: (text, record, index) => {
                    return (
                        <div>
                            {
                                dataTable[index].clicked==="vip"?
                                <div className="vip-edit-div-networksCtl"  >
                                    <div className="vip-edit-input-div-networksCtl">
                                        <Input
                                            value={text}
                                            autoFocus
                                            onChange={self.onEdit.bind(self,index,"vip")}
                                        />
                                    </div>
                                    <div className="vip-edit-ok-div-networksCtl" onClick={self.onClickEditOk.bind(self,index,"vip")}>
                                        <img className="vip-edit-ok-img-networksCtl" src={editYesImg} />
                                    </div>
                                    <div className="vip-edit-no-div-networksCtl" onClick={self.onClickEditNo.bind(self,index,"vip")}>
                                        <img className="vip-edit-no-img-networksCtl" src={editNoImg} />
                                    </div>
                                    <div className="clear-float-div-common" ></div >
                                </div>
                                :
                                <div className="vip-text-div-networksCtl" onClick={self.onClickText.bind(self,index,"vip")} >
                                    {text}
                                </div>
                            }
                        </div>
                    );
                } 
            });
        }

        columns.push({
            title:self.state.i18n.type,
            dataIndex: 'type',
            key: 'type',
            width:'122px',
            render: (text, record, index) => {
                return (
                    <div>
                        <Select 
                            value={text} 
                            onChange={self.onChangeSelect.bind(self,index,"type")}
                            style={{ width: 110 }} 
                        >
                            <Option value="MANAGEMENT">{self.state.i18n.management}</Option>
                            <Option value="REGISTRATION">{self.state.i18n.registration}</Option>
                            <Option value="ISOLATION">{self.state.i18n.isolation}</Option>
                            <Option value="PORTAL">{self.state.i18n.portal}</Option>
                            {/*<Option value="NONE">{self.state.i18n.none}</Option>
                            <Option value="OTHER">{self.state.i18n.other}</Option>*/}
                        </Select>
                    </div>
                );
            } 
        });

        columns.push({
            title: self.state.i18n.services,
            dataIndex: 'services',
            key: 'services',
            width:'112px',
            render: (text, record, index) => {
                return (
                    <div>
                        <Select 
                            value={text} 
                            onChange={self.onChangeSelect.bind(self,index,"services")}
                            style={{ width: 100 }} 
                            mode="multiple"
                        >
                            <Option value="PORTAL">{self.state.i18n.portal}</Option>
                            <Option value="RADIUS">{self.state.i18n.radius}</Option>
                        </Select>
                    </div>
                );
            } 
        });

        columns.push({
            title: self.state.i18n.vlan,
            dataIndex: 'vlan',
            key: 'vlan',
            width:'122px',
            render: (text, record, index) => {
                return (
                    text.indexOf("VLAN")===-1?
                    <div className="vlan-add-div-networksCtl" onClick={self.onClickAddVlan.bind(self,index)}  >
                        <div className="vlan-add-img-div-networksCtl">
                            <img className="vlan-add-img-img-networksCtl" src={addVlanImg} />
                        </div>
                        <div className="vlan-add-text-div-networksCtl">
                            {self.state.i18n.addVlan}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>
                    :
                    <div className="vlan-remove-div-networksCtl" onClick={self.onClickRemoveVlan.bind(self,index)}  >
                        <div className="vlan-remove-img-div-networksCtl">
                            <img className="vlan-remove-img-img-networksCtl" src={removeVlanImg} />
                        </div>
                        <div className="vlan-remove-text-div-networksCtl">
                            {self.state.i18n.removeVlan}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>
                );
            } 
        });

        
        return (
            <div className="global-div-networksCtl">
            <Spin spinning={loading}>
                <div className="left-div-networksCtl">
                    <Guidance 
                        title={self.state.i18n.instructions} 
                        content={[self.state.i18n.instructionsMessage1,self.state.i18n.instructionsMessage2,self.state.i18n.instructionsMessage3]} 
                    />
                    <div className="img-div-networksCtl">
                       <img src={networksImg} className="img-img-networksCtl" />
                    </div>
                    <div className="clear-float-div-common" ></div >
                </div>

                <div className="right-div-networksCtl">
                    
                    <Form onSubmit={self.handleSubmit.bind(self)}>
                    <div className="form-item-div-networksCtl">
                        <div className="form-item-title-div-networksCtl">
                            {self.state.i18n.hostName}
                        </div>
                        <div className="form-item-input-div-networksCtl">
                            {getFieldDecorator('hostname', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckHostname.bind(self)}
                                maxLength={64}
                                />
                            )}
                        </div>
                        <div className="form-item-wrong-div-networksCtl" 
                        style={{display:wrongMessage.hostnameWrongMessage===""?"none":"block"}}>
                                {wrongMessage.hostnameWrongMessage}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="interfaces-div-networksCtl">
                        {self.state.i18n.interfaces}
                    </div>
                    <div className="enable-clustering-div-networksCtl">
                        <div className="enable-clustering-checkbox-div-networksCtl">
                            <Checkbox 
                                checked={enableClustering}
                                onChange={self.onChangeCheckbox.bind(self)}
                            ></Checkbox>
                        </div>
                        <div className="enable-clustering-text-div-networksCtl">
                            {self.state.i18n.enableClustering}
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="table-div-networksCtl">
                        <Table 
                            columns={columns} 
                            dataSource={dataTable} 
                            pagination={false}
                            rowClassName={
                                (record,index)=>
                                     index%2===0?"table-single-row-div-networksCtl":"table-double-row-div-networksCtl"
                                
                            }
                        />
                    </div>

                    <div className="form-button-div-networksCtl">
                        <div className="form-button-next-div-networksCtl">
                            <Button 
                                type="primary" 
                                className="form-button-next-antd-button-networksCtl" 
                                htmlType="submit" 
                            >{self.state.i18n.next}</Button>
                        </div>
                        <div className="form-button-cancel-div-networksCtl">
                            <Button 
                                className="form-button-cancel-antd-button-networksCtl" 
                                onClick={self.onClickCancel.bind(self)}
                            >{self.state.i18n.cancel}</Button>
                        </div>
                    </div>

                    </Form>


                    <div className="clear-float-div-common" ></div >
                </div>

                <Modal 
                    title={self.state.i18n.addVlan}
                    visible={addVlanVisible}
                    width={302}
                    footer={null}
                    maskClosable={false}
                    onCancel={self.onCancelAddVlan.bind(self)}
                >
         
                    <div className="modal-div-networksCtl">
                        
                        <Form onSubmit={self.onOkAddVlan.bind(self)}>
                        <div className="modal-form-item-div-networksCtl" style={{marginTop:"0px"}}>
                            <div className="modal-form-item-title-div-networksCtl">
                                {self.state.i18n.modalName}
                            </div>
                            <div className="modal-form-item-input-div-networksCtl">
                                <div className="modal-form-item-name-vlan-div-networksCtl">
                                    {self.state.i18n.vlan}
                                </div>
                                <div className="modal-form-item-name-number-div-networksCtl">
                                    {getFieldDecorator('name', {
                                        rules: [],
                                    })(
                                        <Input 
                                        style={{height:"32px"}}
                                        onBlur={self.onBlurCheckName.bind(self)}
                                        />
                                    )}
                                </div>
                            </div>
                            <div className="modal-form-item-wrong-div-networksCtl" 
                            style={{color:wrongMessage.nameWrongMessage===""?"#ffffff":"#f44336"}}>
                                    {wrongMessage.nameWrongMessage}
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>


                        <div className="modal-form-item-div-networksCtl">
                            <div className="modal-form-item-title-div-networksCtl">
                                {self.state.i18n.modalIpAddress}
                            </div>
                            <div className="modal-form-item-input-div-networksCtl">
                                {getFieldDecorator('ip_addr', {
                                    rules: [],
                                })(
                                    <Input 
                                    style={{height:"32px"}}
                                    onBlur={self.onBlurCheckIpAddr.bind(self)}
                                    
                                    />
                                )}
                            </div>
                            <div className="modal-form-item-wrong-div-networksCtl" 
                            style={{color:wrongMessage.ipAddrWrongMessage===""?"#ffffff":"#f44336"}}>
                                    {wrongMessage.ipAddrWrongMessage}
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>

                        <div className="modal-form-item-div-networksCtl">
                            <div className="modal-form-item-title-div-networksCtl">
                                {self.state.i18n.modalNetmask}
                            </div>
                            <div className="modal-form-item-input-div-networksCtl">
                                {getFieldDecorator('netmask', {
                                    rules: [],
                                })(
                                    <Input 
                                    style={{height:"32px"}}
                                    onBlur={self.onBlurCheckNetmask.bind(self)}
                                    
                                    />
                                )}
                            </div>
                            <div className="modal-form-item-wrong-div-networksCtl" 
                            style={{color:wrongMessage.netmaskWrongMessage===""?"#ffffff":"#f44336"}}>
                                    {wrongMessage.netmaskWrongMessage}
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>

                        <div className="modal-form-item-div-networksCtl" 
                            style={{display:enableClustering===true?"block":"none"}}
                        >
                            <div className="modal-form-item-title-div-networksCtl">
                                {self.state.i18n.vip}
                            </div>
                            <div className="modal-form-item-input-div-networksCtl">
                                {getFieldDecorator('vip', {
                                    rules: [],
                                })(
                                    <Input 
                                    style={{height:"32px"}}
                                    onBlur={self.onBlurCheckVip.bind(self)}
                                    
                                    />
                                )}
                            </div>
                            <div className="modal-form-item-wrong-div-networksCtl" 
                            style={{color:wrongMessage.vipWrongMessage===""?"#ffffff":"#f44336"}}>
                                    {wrongMessage.vipWrongMessage}
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>


                        <div className="modal-form-item-div-networksCtl">
                            <div className="modal-form-item-title-div-networksCtl">
                                {self.state.i18n.modalType}
                            </div>
                            <div className="modal-form-item-input-div-networksCtl">
                                {getFieldDecorator('type', {
                                    rules: [],
                                    initialValue:"MANAGEMENT",
                                })(

                                    <Select 
                                        option={{initialValue:"MANAGEMENT"}}
                                        style={{ height: 32 }} 
                                    >
                                        <Option value="MANAGEMENT" >{self.state.i18n.management}</Option>
                                        <Option value="REGISTRATION">{self.state.i18n.registration}</Option>
                                        <Option value="ISOLATION" >{self.state.i18n.isolation}</Option>
                                        <Option value="PORTAL">{self.state.i18n.portal}</Option>
                                        {/*<Option value="NONE" >{self.state.i18n.none}</Option>
                                        <Option value="OTHER" >{self.state.i18n.other}</Option>*/}
                                    </Select>

                                )}
                            </div>
                            <div className="modal-form-item-wrong-div-networksCtl">
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>
                        <div className="modal-form-item-div-networksCtl">
                            <div className="modal-form-item-title-div-networksCtl">
                                {self.state.i18n.modalServices}
                            </div>
                            <div className="modal-form-item-input-div-networksCtl">
                                {getFieldDecorator('services', {
                                    rules: [],
                                    initialValue:["PORTAL"],
                                })(
                                    <Select 
                                        mode="multiple"
                                        style={{ height: 32 }} 
                                    >
                                        <Option value="PORTAL">{self.state.i18n.portal}</Option>
                                        <Option value="RADIUS">{self.state.i18n.radius}</Option>
                                    </Select>
                                )}
                            </div>
                            <div className="modal-form-item-wrong-div-networksCtl">
                            </div>
                            <div className="clear-float-div-common" ></div >
                        </div>
                        <div className="modal-form-button-div-networksCtl">
                            <div className="modal-form-button-next-div-networksCtl">
                                <Button 
                                    type="primary" 
                                    className="modal-form-button-next-antd-button-networksCtl" 
                                    htmlType="submit" 
                                >{self.state.i18n.save}</Button>
                            </div>
                            <div className="modal-form-button-cancel-div-networksCtl">
                                <Button 
                                    className="modal-form-button-cancel-antd-button-networksCtl" 
                                    onClick={self.onCancelAddVlan.bind(self)}
                                >{self.state.i18n.cancel}</Button>
                            </div>
                        </div>
                        </Form>


                
                        <div className="clear-float-div-common" ></div >
                    </div>
            
                </Modal>
                <div className="clear-float-div-common" ></div >
            </Spin>


            
            </div>
            
        )
    }
}


export default Form.create()(networksCtl);



