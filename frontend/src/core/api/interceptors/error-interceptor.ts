 
import { AxiosError } from 'axios';
import { tokenUtils } from '../../utils/token.utils';
import { authStore } from '../../store/authStore';

export const errorInterceptor = async (error: AxiosError) => {
  const originalRequest = error.config as any;

  // Handle 401 Unauthorized
  if (error.response?.status === 401 && !originalRequest._retry) {
    originalRequest._retry = true;

    try {
      const refreshToken = tokenUtils.getRefreshToken();
      if (refreshToken) {
        // Attempt to refresh token
        const response = await apiClient.post<{ accessToken: string }>('/auth/refresh-token', {
          refreshToken,
        });
        
        tokenUtils.setAccessToken(response.data.accessToken);
        
        // Retry original request
        originalRequest.headers.Authorization = `Bearer ${response.data.accessToken}`;
        return apiClient.clientInstance(originalRequest);
      }
    } catch (refreshError) {
      // Refresh failed - logout
      authStore.getState().logout();
    }
  }

  // Handle other errors
  const errorMessage = (error.response?.data as any)?.message || error.message || 'An error occurred';
  
  return Promise.reject({
    status: error.response?.status,
    message: errorMessage,
    errors: (error.response?.data as any)?.errors,
  });
};