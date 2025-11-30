package com.selimhorri.app.config.filter;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.util.Arrays;  
import java.util.List; 
import com.selimhorri.app.jwt.service.JwtService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
@RequiredArgsConstructor
public class JwtRequestFilter extends OncePerRequestFilter {
	
	private final UserDetailsService userDetailsService;
	private final JwtService jwtService;

	private static final List<String> EXCLUDED_PATHS = Arrays.asList(
        "/app/actuator/prometheus",
        "/app/actuator/metrics",
        "/app/actuator/health",
        "/app/actuator/info",
        "/app/actuator"
	);

	@Override
	protected boolean shouldNotFilter(HttpServletRequest request) {
		String path = request.getRequestURI();

		boolean excluded = EXCLUDED_PATHS.stream()
				.anyMatch(path::startsWith);

		return excluded;
	}

	
	@Override
	protected void doFilterInternal(final HttpServletRequest request, final HttpServletResponse response, final FilterChain filterChain) 
			throws ServletException, IOException {
		
		log.info("**JwtRequestFilter, once per request, validating and extracting token*\n");
		
		final var authorizationHeader = request.getHeader("Authorization");
		
		String username = null;
		String jwt = null;
		
		if ( authorizationHeader != null && authorizationHeader.startsWith("Bearer ") ) {
			jwt = authorizationHeader.substring(7);
			username = jwtService.extractUsername(jwt);
		}
		
		if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
			
			final UserDetails userDetails = this.userDetailsService.loadUserByUsername(username);
			
			if (this.jwtService.validateToken(jwt, userDetails)) {
				final UsernamePasswordAuthenticationToken usernamePasswordAuthenticationToken = 
						new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
				usernamePasswordAuthenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
				SecurityContextHolder.getContext().setAuthentication(usernamePasswordAuthenticationToken);
			}
			
		}
		
		filterChain.doFilter(request, response);
		log.info("**Jwt request filtered!*\n");
	}
	
	
	
}










