import apiCall from '@/utils/api'

export default {
  /**
   * Roles
   */
  role: id => {
    return apiCall.get(`config/role/${id}`).then(response => {
      return response.data.item
    })
  },
  createRole: data => {
    return apiCall.post('config/roles', data).then(response => {
      return response.data
    })
  },
  updateRole: data => {
    return apiCall.patch(`config/role/${data.id}`, data).then(response => {
      return response.data
    })
  },
  deleteRole: id => {
    return apiCall.delete(`config/role/${id}`)
  },
  /**
   * Domains
   */
  domains: params => {
    return apiCall.get('config/domains', { params }).then(response => {
      return response.data
    })
  },
  domain: id => {
    return apiCall.get(`config/domain/${id}`).then(response => {
      return response.data.item
    })
  },
  createDomain: data => {
    return apiCall.post('config/domains', data).then(response => {
      return response.data
    })
  },
  updateDomain: data => {
    return apiCall.patch(`config/domain/${data.id}`, data).then(response => {
      return response.data
    })
  },
  deleteDomain: id => {
    return apiCall.delete(`config/domain/${id}`)
  },
  /**
   * Realms
   */
  realm: id => {
    return apiCall.get(`config/realm/${id}`).then(response => {
      return response.data.item
    })
  },
  createRealm: data => {
    return apiCall.post('config/realms', data).then(response => {
      return response.data
    })
  },
  updateRealm: data => {
    return apiCall.patch(`config/realm/${data.id}`, data).then(response => {
      return response.data
    })
  },
  deleteRealm: id => {
    return apiCall.delete(`config/realm/${id}`)
  },
  /**
   * Floating Devices
   */
  floatingDevice: id => {
    return apiCall.get(`config/floating_device/${id}`).then(response => {
      return response.data.item
    })
  },
  createFloatingDevice: data => {
    return apiCall.post('config/floating_devices', data).then(response => {
      return response.data
    })
  },
  updateFloatingDevice: data => {
    return apiCall.patch(`config/floating_device/${data.id}`, data).then(response => {
      return response.data
    })
  },
  deleteFloatingDevice: id => {
    return apiCall.delete(`config/floating_device/${id}`)
  }
}
