import axios, { type AxiosRequestConfig } from 'axios';

const API_URL = import.meta.env.VITE_API_URL;

type ApiRequestOptions = {
  method?: AxiosRequestConfig['method'];
  data?: unknown;
  params?: AxiosRequestConfig['params'];
};

export async function apiRequest<T>(
  path: string,
  token: string | null,
  options: ApiRequestOptions = {}
): Promise<T> {
  if (!API_URL) {
    throw new Error('Не задан адрес API в переменной VITE_API_URL');
  }

  try {
    const response = await axios.request<T>({
      method: options.method,
      url: `${API_URL}${path}`,
      data: options.data,
      params: options.params,
      headers: token
        ? { Authorization: `Bearer ${token}` }
        : undefined,
    });

    if (response.status === 204) {
      return undefined as T;
    }

    return response.data;
  } catch (error) {
    if (axios.isAxiosError(error)) {
      const responseData = error.response?.data as
        | { detail?: string; message?: string }
        | undefined;

      const errorMessage =
        responseData?.detail ||
        responseData?.message ||
        error.message ||
        'Не удалось выполнить запрос';

      throw new Error(errorMessage, { cause: error });
    }

    throw error;
  }
}