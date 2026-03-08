 
import { apiClient } from '../client';
import { 
  LoginRequest, 
  LoginResponse, 
  RefreshTokenRequest,
  ChangePasswordRequest,
  ForgotPasswordRequest,
  ResetPasswordRequest,
  UserInfo 
} from '../../types/auth.types';

class AuthService {
  private static instance: AuthService;
  private baseUrl = '/auth';

  private constructor() {}

  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }

  async login(request: LoginRequest): Promise<LoginResponse> {
    return apiClient.post<LoginResponse>(`${this.baseUrl}/login`, request);
  }

  async refreshToken(request: RefreshTokenRequest): Promise<LoginResponse> {
    return apiClient.post<LoginResponse>(`${this.baseUrl}/refresh-token`, request);
  }

  async logout(): Promise<void> {
    return apiClient.post(`${this.baseUrl}/logout`);
  }

  async logoutAll(): Promise<void> {
    return apiClient.post(`${this.baseUrl}/logout-all`);
  }

  async changePassword(request: ChangePasswordRequest): Promise<LoginResponse> {
    return apiClient.post<LoginResponse>(`${this.baseUrl}/change-password`, request);
  }

  async forgotPassword(request: ForgotPasswordRequest): Promise<void> {
    return apiClient.post(`${this.baseUrl}/forgot-password`, request);
  }

  async resetPassword(request: ResetPasswordRequest): Promise<void> {
    return apiClient.post(`${this.baseUrl}/reset-password`, request);
  }

  async getCurrentUser(): Promise<UserInfo> {
    return apiClient.get<UserInfo>(`${this.baseUrl}/current`);
  }

  async checkPermission(permissionCode: string): Promise<boolean> {
    const response = await apiClient.get<{ hasPermission: boolean }>(
      `${this.baseUrl}/check-permission/${permissionCode}`
    );
    return response.hasPermission;
  }

  async getUserPermissions(): Promise<string[]> {
    return apiClient.get<string[]>(`${this.baseUrl}/permissions`);
  }
}

export const authService = AuthService.getInstance();