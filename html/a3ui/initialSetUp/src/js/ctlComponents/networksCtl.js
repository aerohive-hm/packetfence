import React from 'react';
import ReactPasswordStrength from 'react-password-strength';
import zxcvbn from 'zxcvbn';
import { Form, Button,Switch,Icon,message,Input, Checkbox,Row,Tree,Radio  ,Select,Spin,Tooltip ,Table,Modal } from 'antd';
const { TextArea } = Input;
const RadioGroup = Radio.Group;
const Option = Select.Option;
const FormItem = Form.Item;

import {RequestApi,UnixToDate,urlEncode,formatNum,isEmail} from "../../libs/util";     
import '../../css/ctlComponents/networksCtl.css';
import '../../libs/common.css';

import * as mock from "../../libs/mockData";
import Guidance from "../../libs/guidance/js/guidance";
import $ from 'jquery';
import {i18nfr} from "../../i18n/ctlComponents/nls/fr/networksCtl";
import {i18n} from "../../i18n/ctlComponents/nls/networksCtl";

import networksImg from "../../media/networks.png";
import editNoImg from "../../media/editNo.png";
import editYesImg from "../../media/editYes.png";
import addVlanImg from "../../media/addVlan.png";
import removeVlanImg from "../../media/removeVlan.png";




const {Component} = React;

class networksCtl extends Component {
    constructor(props) {
        super(props);
        this.state = {
            i18n:{},
            wrongMessage:{
                hostnameWrongMessage:"",
            },
            enableClustering:true,
            loading:false,
            dataTable:[],
            isEditing:false,
            originalDescription:"",
        };


    }
    

    componentDidMount() {
        let self=this;
        self.getRightI18n();
        self.getData();
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

    getData= () => {
        let self=this;

        let url= "/a3/api/v1/configurator/networks";
         
        let param={
        }
        
        self.setState({
            loading : true,
        })

        // new RequestApi('get',url,param,xCsrfToken,(data)=>{
        //     self.getTureData(data);
        // });

        self.getTureData(mock.networks);
    }

    getTureData= (data) => {
        let self=this;
        let dataTable=data.items;
        for(let i=0;i<dataTable.length;i++){
            dataTable[i].key=dataTable[i].id;
            dataTable[i].vlan=dataTable[i].name;
            dataTable[i].clicked="";
        }
        self.setState({
            dataTable: dataTable,
            loading : false,
        }); 
    }


    onChangeCheckbox=(e)=>{
        let self=this;
        this.setState({
            enableClustering: e.target.checked,
        });
    }

    onBlurCheckHostname(e){
        let self=this;
        self.checkHostname(e.target.value);
    }

    checkHostname=(hostname)=>{
        let self=this;
        let newWrongMessage=self.state.wrongMessage;

        if(!hostname||hostname.toString().trim()===""){
            newWrongMessage.hostnameWrongMessage="Host Name is required.";
        }else{
            newWrongMessage.hostnameWrongMessage="";
        }


        self.setState({
            wrongMessage:newWrongMessage
        })
        if(newWrongMessage.hostnameWrongMessage===""){
            $("#hostname").css({
                "border":"1px solid #999999",
            });
            return true;
        }else{
            $("#hostname").css({
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
                if(self.checkHostname(values.hostname)===false){
                    hasWrongValue=true;
                    $("#hostname").focus();
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

    onClickText= (index,column) => {
        let self=this;
        
        if(self.state.isEditing===true){
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
        dataCopy[index][column]=e.target.value;
        self.setState({ 
            dataTable : dataCopy, 
        });

    }

    onChangeSelect=(index,column,value) =>{
        let self=this;
        let dataCopy=self.state.dataTable;
        dataCopy[index][column]=value;
        self.setState({ 
            dataTable : dataCopy, 
        });

    }


    onClickEditOk= (index) => {
        let self=this;
        let dataCopy=self.state.dataTable;
        dataCopy[index].clicked="";
        self.setState({
            dataTable : dataCopy,
            isEditing: false,
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


    render() {
        const {wrongMessage,enableClustering,dataTable,loading} = this.state;
        const {} = this.props;
        const { getFieldDecorator } = this.props.form;
        let self = this;
        message.config({
            duration: 10,
        });

        let columns=[];
        columns.push({
            title:"NAME",
            dataIndex: 'name',
            key: 'name',
            render: (text, record, index) => {
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
                            {text}
                        </div>
                    </div>
                );
            } 
        });
        columns.push({
            title: "IP ADDRESS",
            dataIndex: 'ip_addr',
            key: 'ip_addr',
            render: (text, record, index) => {
                return (
                    <div>
                        {
                            dataTable[index].clicked==="ip_addr"?
                            <div className=""  >
                                <div className="ipAddr-edit-input-div-networksCtl">
                                    <Input
                                        value={text}
                                        autoFocus
                                        onChange={self.onEdit.bind(self,index,"ip_addr")}
                                    />
                                </div>
                                <div className="ipAddr-edit-ok-div-networksCtl" onClick={self.onClickEditOk.bind(self,index)}>
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
            title:"NETMASK",
            dataIndex: 'netmask',
            key: 'netmask',
            render: (text, record, index) => {
                return (
                    <div>
                        {
                            dataTable[index].clicked==="netmask"?
                            <div className=""  >
                                <div className="netmask-edit-input-div-networksCtl">
                                    <Input
                                        value={text}
                                        autoFocus
                                        onChange={self.onEdit.bind(self,index,"netmask")}
                                    />
                                </div>
                                <div className="netmask-edit-ok-div-networksCtl" onClick={self.onClickEditOk.bind(self,index)}>
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
        columns.push({
            title:"VIP",
            dataIndex: 'vip',
            key: 'vip',
            render: (text, record, index) => {
                return (
                    <div>
                        {
                            dataTable[index].clicked==="vip"?
                            <div className=""  >
                                <div className="vip-edit-input-div-networksCtl">
                                    <Input
                                        value={text}
                                        autoFocus
                                        onChange={self.onEdit.bind(self,index,"vip")}
                                    />
                                </div>
                                <div className="vip-edit-ok-div-networksCtl" onClick={self.onClickEditOk.bind(self,index)}>
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
        columns.push({
            title:"TYPE",
            dataIndex: 'type',
            key: 'type',
            render: (text, record, index) => {
                return (
                    <div>
                        <Select 
                            value={text} 
                            onChange={self.onChangeSelect.bind(self,index,"type")}
                            style={{ width: 110 }} 
                        >
                            <Option value="management">management</Option>
                            <Option value="registration">registration</Option>
                        </Select>
                    </div>
                );
            } 
        });

        columns.push({
            title: 'SERVICES',
            dataIndex: 'services',
            key: 'services',
            render: (text, record, index) => {
                return (
                    <div>
                        <Select 
                            value={text} 
                            onChange={self.onChangeSelect.bind(self,index,"services")}
                            style={{ width: 110 }} 
                        >
                            <Option value="portal">portal</Option>
                        </Select>
                    </div>
                );
            } 
        });

        columns.push({
            title: "VLAN",
            dataIndex: 'vlan',
            key: 'vlan',
            render: (text, record, index) => {
                return (
                    text.indexOf("VLAN")===-1?
                    <div className="vlan-add-div-networksCtl"  >
                        <div className="vlan-add-img-div-networksCtl">
                            <img src={addVlanImg} className="vlan-add-img-img-networksCtl" />
                        </div>
                        <div className="vlan-add-text-div-networksCtl">
                            {text}
                        </div>
                    </div>
                    :
                    <div className="vlan-remove-div-networksCtl">
                        <div className="vlan-remove-img-div-networksCtl">
                            <img src={removeVlanImg} className="vlan-remove-img-img-networksCtl" />
                        </div>
                        <div className="vlan-remove-text-div-networksCtl">
                            {text}
                        </div>
                    </div>
                );
            } 
        });

        
        return (
            <div className="global-div-networksCtl">
            <Spin spinning={loading}>
                <div className="left-div-networksCtl">
                    <Guidance 
                        title={"Networks"} 
                        content={"awgwaegWEE EEEEEEEEEE EEEEEEWfeWEFABERBAR WRBRAEBAERBBEABAWRBAERBAER BAEBABRAEBVAWRVAERBAERBAERBAERBAER BawgwaegWEEEE EEEEEEEEEEEEEEWfeWEFABERBA RWRBRAEBAERBBEABAWRBAE RBAERBAEB ABRAEBVAWR  VAERBAERBA ERBAERBAER BawgwaegWE EEEEEEEEEEE EEEEEEWfeWE FABERBARWRB RAEBAERBBEA BAWRBAER BAERBAEBAB RAEBVAWRVAERB AERBAERBAERBAERB ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"} 
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
                            Host Name
                        </div>
                        <div className="form-item-input-div-networksCtl">
                            {getFieldDecorator('hostname', {
                                rules: [],
                            })(
                                <Input 
                                style={{height:"32px"}}
                                onBlur={self.onBlurCheckHostname.bind(self)}
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
                        interfaces
                    </div>
                    <div className="enable-clustering-div-networksCtl">
                        <div className="enable-clustering-checkbox-div-networksCtl">
                            <Checkbox 
                                value={enableClustering}
                                onChange={self.onChangeCheckbox.bind(self)}
                            ></Checkbox>
                        </div>
                        <div className="enable-clustering-text-div-networksCtl">
                            Enable clustering
                        </div>
                        <div className="clear-float-div-common" ></div >
                    </div>

                    <div className="table-div-networksCtl">
                        <Table 
                            columns={columns} 
                            dataSource={dataTable} 
                            pagination={false}
                        />
                    </div>

                    <div className="form-button-div-networksCtl">
                        <div className="form-button-next-div-networksCtl">
                            <Button 
                                type="primary" 
                                className="form-button-next-antd-button-networksCtl" 
                                htmlType="submit" 
                            >NEXT</Button>
                        </div>
                        <div className="form-button-cancel-div-networksCtl">
                            <Button 
                                className="form-button-cancel-antd-button-networksCtl" 
                                onClick={self.onClickCancel.bind(self)}
                            >CANCEL</Button>
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


export default Form.create()(networksCtl);



