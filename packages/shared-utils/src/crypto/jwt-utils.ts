 
import jwt from 'jsonwebtoken';

export interface JwtPayload {
  sub: string;
  email: string;
  roles: string[];
  permissions: string[];
  [key: string]: any;
}

export interface JwtOptions {
  secret: string;
  expiresIn?: string | number;
  issuer?: string;
  audience?: string;
}

export class JwtUtils {
  /**
   * Generates a JWT token
   */
  static generateToken(
    payload: JwtPayload,
    options: JwtOptions
  ): string {
    const { secret, expiresIn = '1h', issuer, audience } = options;
    
    return jwt.sign(payload, secret, {
      expiresIn,
      issuer,
      audience,
      algorithm: 'HS256'
    });
  }

  /**
   * Verifies and decodes a JWT token
   */
  static verifyToken<T extends JwtPayload>(
    token: string,
    options: JwtOptions
  ): T | null {
    try {
      const { secret, issuer, audience } = options;
      
      const decoded = jwt.verify(token, secret, {
        issuer,
        audience,
        algorithms: ['HS256']
      }) as T;
      
      return decoded;
    } catch (error) {
      return null;
    }
  }

  /**
   * Decodes a JWT token without verification
   */
  static decodeToken<T extends JwtPayload>(token: string): T | null {
    try {
      return jwt.decode(token) as T;
    } catch {
      return null;
    }
  }

  /**
   * Extracts token from Authorization header
   */
  static extractTokenFromHeader(authHeader?: string): string | null {
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }
    
    return authHeader.substring(7);
  }

  /**
   * Checks if token is expired
   */
  static isTokenExpired(token: string): boolean {
    try {
      const decoded = jwt.decode(token) as { exp?: number };
      if (!decoded || !decoded.exp) {
        return true;
      }
      
      const currentTime = Math.floor(Date.now() / 1000);
      return decoded.exp < currentTime;
    } catch {
      return true;
    }
  }

  /**
   * Gets token expiration time
   */
  static getTokenExpiration(token: string): Date | null {
    try {
      const decoded = jwt.decode(token) as { exp?: number };
      if (!decoded || !decoded.exp) {
        return null;
      }
      
      return new Date(decoded.exp * 1000);
    } catch {
      return null;
    }
  }
}