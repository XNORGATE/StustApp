// ignore_for_file: non_constant_identifier_names

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';

// Global options
final options = CacheOptions(
  // A default store is required for interceptor.
  store: MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576),

  // All subsequent fields are optional.

  // Default.
  policy: CachePolicy.request,
  // Returns a cached response on error but for statuses 401 & 403.
  // Also allows to return a cached response on network errors (e.g. offline usage).
  // Defaults to [null].
  hitCacheOnErrorExcept: [],
  // Overrides any HTTP directive to delete entry past this duration.
  // Useful only when origin server has no cache config or custom behaviour is desired.
  // Defaults to [null].
  maxStale: const Duration(days: 7),
  // Default. Allows 3 cache sets and ease cleanup.
  priority: CachePriority.normal,
  // Default. Body and headers encryption with your own algorithm.
  cipher: null,
  // Default. Key builder to retrieve requests.
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  // Default. Allows to cache POST requests.
  // Overriding [keyBuilder] is strongly recommended when [true].
  allowPostMethod: false,
);

// // Add cache interceptor with global/default options
// final dio = Dio()..interceptors.add(DioCacheInterceptor(options: options));

// // ...

// // Requesting with global options => status(200) => Content is written to cache store
// var response = await dio.get('https://www.foo.com');
// // Requesting with global options => status(304) => Content is read from cache store
// response = await dio.get('https://www.foo.com');

// // Requesting by modifying policy with refresh option
// // for this single request => status(200) => Content is written to cache store
// response = await dio.get('https://www.foo.com',
//   options: options.copyWith(policy: CachePolicy.refresh).toOptions(),
// );

mixin DioCacheMixin<T extends StatefulWidget> on State<T> {
  late CacheStore cacheStore;
  late CacheOptions cacheOptions;
  // late Dio DioCache;
  // late Caller caller;

  @override
  void initState() {
    cacheStore = MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576);
    cacheOptions = CacheOptions(
      // A default store is required for interceptor.
      store: cacheStore,

      // All subsequent fields are optional.

      // Default.
      policy: CachePolicy.request,
      // Returns a cached response on error but for statuses 401 & 403.
      // Also allows to return a cached response on network errors (e.g. offline usage).
      // Defaults to [null].
      hitCacheOnErrorExcept: [],
      // Overrides any HTTP directive to delete entry past this duration.
      // Useful only when origin server has no cache config or custom behaviour is desired.
      // Defaults to [null].
      maxStale: const Duration(days: 7),
      // Default. Allows 3 cache sets and ease cleanup.
      priority: CachePriority.normal,
      // Default. Body and headers encryption with your own algorithm.
      cipher: null,
      // Default. Key builder to retrieve requests.
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      // Default. Allows to cache POST requests.
      // Overriding [keyBuilder] is strongly recommended when [true].
      allowPostMethod: false,
    );

    // DioCache = Dio( )
    //   ..interceptors.add(
    //     DioCacheInterceptor(options: cacheOptions),
    //   );

    // caller = Caller(
    //   cacheStore: cacheStore,
    //   cacheOptions: cacheOptions,
    //   dio: dio,
    // );

    super.initState();
  }
}
