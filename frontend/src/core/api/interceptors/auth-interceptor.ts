 
import { InternalAxiosRequestConfig } from 'axios';
import { tokenUtils } from '../../utils/token.utils';

export const authInterceptor = (config: InternalAxiosRequestConfig): InternalAxiosRequestConfig => {
  const token = tokenUtils.getAccessToken();
  
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  
  return config;
};